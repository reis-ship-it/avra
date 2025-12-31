#!/usr/bin/env python3
"""
Hybrid Training Data Generator for Calling Score Model
Phase 12 Section 2: Neural Network Implementation

Generates training data using Big Five converted profiles as user vibes,
combined with synthetic spot vibes, context, timing, and outcomes.

This provides better personality distributions than 100% synthetic data
while still being synthetic for spots/context/timing/outcomes.

Usage:
    # First, convert Big Five dataset to SPOTS format:
    python scripts/knot_validation/data_converter.py data/raw/big_five.csv --output data/raw/big_five_spots.json
    
    # Then generate hybrid training data:
    python scripts/ml/generate_hybrid_training_data.py \
      data/raw/big_five_spots.json \
      --output data/calling_score_training_data_hybrid.json \
      --num-samples 10000
"""

import argparse
import json
import os
import random
import sys
from pathlib import Path
from typing import Dict, List

import numpy as np

# Add scripts/ml to path for dataset_base import
scripts_ml_path = Path(__file__).parent
sys.path.insert(0, str(scripts_ml_path))

# Import new dataset architecture
from dataset_base import TrainingDataset, TrainingRecord, DatasetMetadata


def load_spots_profiles(spots_profiles_path: Path) -> List[Dict]:
    """Load SPOTS profiles from data_converter output"""
    if not spots_profiles_path.exists():
        raise FileNotFoundError(f"SPOTS profiles file not found: {spots_profiles_path}")
    
    with open(spots_profiles_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Handle different JSON structures
    if isinstance(data, list):
        return data
    elif isinstance(data, dict) and 'profiles' in data:
        return data['profiles']
    elif isinstance(data, dict) and 'data' in data:
        return data['data']
    else:
        # Assume it's a single profile
        return [data]


def map_spots_dimensions_to_training_format(spots_dimensions: Dict) -> Dict:
    """
    Map SPOTS dimensions from data_converter output to training format.
    
    data_converter uses slightly different dimension names:
    - 'adventure_seeking' → 'location_adventurousness'
    - 'authenticity' → 'authenticity_preference'
    - 'trust_level' → 'trust_network_reliance'
    - 'openness' → can be used for 'overall_energy'
    - 'social_preference' → 'social_preference' (same)
    
    Missing dimensions will be derived or defaulted.
    """
    # Dimension mapping from data_converter names to training format
    dimension_mapping = {
        'exploration_eagerness': 'exploration_eagerness',
        'community_orientation': 'community_orientation',
        'adventure_seeking': 'location_adventurousness',
        'social_preference': 'social_preference',
        'energy_preference': 'energy_preference',
        'novelty_seeking': 'novelty_seeking',
        'value_orientation': 'value_orientation',
        'crowd_tolerance': 'crowd_tolerance',
        'authenticity': 'authenticity_preference',
        'trust_level': 'trust_network_reliance',
        'openness': 'overall_energy',  # Use openness as overall_energy
    }
    
    training_dimensions = {}
    
    # Map known dimensions
    for spots_key, training_key in dimension_mapping.items():
        if spots_key in spots_dimensions:
            value = spots_dimensions[spots_key]
            # Ensure value is in [0.0, 1.0]
            if isinstance(value, (int, float)):
                training_dimensions[training_key] = float(np.clip(value, 0.0, 1.0))
    
    # Required dimensions for training (12 total)
    required_dims = [
        'exploration_eagerness',
        'community_orientation',
        'location_adventurousness',
        'authenticity_preference',
        'trust_network_reliance',
        'temporal_flexibility',
        'energy_preference',
        'novelty_seeking',
        'value_orientation',
        'crowd_tolerance',
        'social_preference',
        'overall_energy',
    ]
    
    # Fill missing dimensions
    # temporal_flexibility: Derive from conscientiousness (if available) or use default
    if 'temporal_flexibility' not in training_dimensions:
        # If we have conscientiousness info, use inverse (high C = low flexibility)
        # Otherwise use exploration_eagerness as proxy
        if 'conscientiousness' in spots_dimensions:
            conscientiousness = float(spots_dimensions['conscientiousness'])
            training_dimensions['temporal_flexibility'] = float(1.0 - conscientiousness)
        elif 'exploration_eagerness' in training_dimensions:
            # More exploration = more flexibility
            training_dimensions['temporal_flexibility'] = training_dimensions['exploration_eagerness']
        else:
            training_dimensions['temporal_flexibility'] = 0.5
    
    # Ensure all required dimensions are present
    for dim in required_dims:
        if dim not in training_dimensions:
            # Use default or derive from other dimensions
            if dim == 'overall_energy' and 'energy_preference' in training_dimensions:
                training_dimensions[dim] = training_dimensions['energy_preference']
            elif dim == 'location_adventurousness' and 'exploration_eagerness' in training_dimensions:
                training_dimensions[dim] = training_dimensions['exploration_eagerness']
            else:
                training_dimensions[dim] = 0.5  # Default
    
    return training_dimensions


def generate_spot_vibe(user_vibe: Dict, seed: int = None) -> Dict:
    """
    Generate spot vibe correlated with user vibe.
    
    Spot vibes should be somewhat compatible with user vibes
    (high compatibility = good match), but with variation.
    """
    if seed is not None:
        np.random.seed(seed)
    
    spot_vibe = {}
    for dim, value in user_vibe.items():
        # Spot vibe is correlated with user vibe but has variation
        # Higher correlation = better matches (which we want for positive outcomes)
        correlation = np.random.uniform(0.6, 0.9)  # 60-90% correlation
        variation = np.random.normal(0, 0.15)  # Small variation
        spot_vibe[dim] = float(np.clip(value * correlation + variation, 0.0, 1.0))
    
    return spot_vibe


def generate_context_features(seed: int = None) -> Dict:
    """Generate context features (synthetic)"""
    if seed is not None:
        np.random.seed(seed)
    
    context_features = {
        'location_proximity': round(float(np.random.beta(2, 2)), 4),
        'journey_alignment': round(float(np.random.beta(2, 2)), 4),
        'user_receptivity': round(float(np.random.beta(2, 2)), 4),
        'opportunity_availability': round(float(np.random.beta(2, 2)), 4),
        'network_effects': round(float(np.random.beta(2, 2)), 4),
        'community_patterns': round(float(np.random.beta(2, 2)), 4),
    }
    
    # Add 4 placeholder context features
    for i in range(4):
        context_features[f'context_feature_{i+7}'] = round(float(np.random.beta(2, 2)), 4)
    
    return context_features


def generate_timing_features(seed: int = None) -> Dict:
    """Generate timing features (synthetic)"""
    if seed is not None:
        np.random.seed(seed)
    
    timing_features = {
        'optimal_time_of_day': round(float(np.random.beta(2, 2)), 4),
        'optimal_day_of_week': round(float(np.random.beta(2, 2)), 4),
        'user_patterns': round(float(np.random.beta(2, 2)), 4),
        'opportunity_timing': round(float(np.random.beta(2, 2)), 4),
        'timing_feature_5': round(float(np.random.beta(2, 2)), 4),
    }
    
    return timing_features


def calculate_formula_calling_score(
    user_vibe: Dict,
    spot_vibe: Dict,
    context_features: Dict,
    timing_features: Dict,
) -> float:
    """
    Calculate formula-based calling score (simplified version).
    
    This mimics the actual formula-based calculation in CallingScoreCalculator.
    """
    # Vibe compatibility (40% weight)
    vibe_compatibility = np.mean([
        1.0 - abs(user_vibe[dim] - spot_vibe[dim])
        for dim in user_vibe.keys()
    ])
    
    # Context factor (10% weight)
    context_factor = np.mean(list(context_features.values())[:6])
    
    # Timing factor (5% weight)
    timing_factor = np.mean(list(timing_features.values())[:4])
    
    # Simplified formula (matching CallingScoreCalculator weights)
    # Note: Actual formula has more components (life betterment, meaningful connection, etc.)
    # This is a simplified version for synthetic data generation
    formula_calling_score = (
        vibe_compatibility * 0.50 +
        context_factor * 0.30 +
        timing_factor * 0.20
    )
    
    return float(np.clip(formula_calling_score, 0.0, 1.0))


def generate_outcome(formula_calling_score: float, is_called: bool, seed: int = None) -> tuple:
    """
    Generate outcome based on calling score.
    
    Returns:
        (outcome_type, outcome_score)
    """
    if seed is not None:
        np.random.seed(seed)
    
    if is_called:
        # Positive outcomes more likely with higher calling scores
        # Add some noise for realism
        outcome_score = float(np.clip(
            formula_calling_score + np.random.normal(0, 0.1),
            0.0, 1.0
        ))
        outcome_type = 'positive' if outcome_score >= 0.7 else 'neutral'
    else:
        # Not called = negative or neutral outcome
        outcome_score = float(np.random.uniform(0.0, 0.5))
        outcome_type = 'negative' if outcome_score < 0.3 else 'neutral'
    
    return outcome_type, outcome_score


def generate_training_record(spots_profile: Dict, record_index: int = 0) -> TrainingRecord:
    """
    Generate training record from SPOTS profile.
    
    Args:
        spots_profile: Profile from data_converter output
        record_index: Index for this record (for seeding)
    
    Returns:
        TrainingRecord object
    """
    # Get user vibe from converted profile
    spots_dimensions = spots_profile.get('dimensions', {})
    user_vibe = map_spots_dimensions_to_training_format(spots_dimensions)
    
    # Generate spot vibe (synthetic, but correlated with user vibe)
    spot_vibe = generate_spot_vibe(user_vibe, seed=record_index)
    
    # Generate context and timing (synthetic)
    context_features = generate_context_features(seed=record_index + 1000)
    timing_features = generate_timing_features(seed=record_index + 2000)
    
    # Calculate calling score
    formula_calling_score = calculate_formula_calling_score(
        user_vibe, spot_vibe, context_features, timing_features
    )
    
    is_called = formula_calling_score >= 0.7
    
    # Generate outcome
    outcome_type, outcome_score = generate_outcome(
        formula_calling_score, is_called, seed=record_index + 3000
    )
    
    # Get user_id from profile if available
    user_id = spots_profile.get('user_id') or spots_profile.get('id')
    
    return TrainingRecord(
        user_vibe_dimensions=user_vibe,
        spot_vibe_dimensions=spot_vibe,
        context_features=context_features,
        timing_features=timing_features,
        formula_calling_score=round(formula_calling_score, 4),
        is_called=is_called,
        outcome_type=outcome_type,
        outcome_score=round(outcome_score, 4),
        user_id=str(user_id) if user_id else None,
    )


def generate_hybrid_dataset(
    spots_profiles_path: Path,
    output_path: Path,
    num_samples: int = 10000,
    records_per_profile: int = None,
):
    """
    Generate hybrid training dataset using new dataset architecture.
    
    Args:
        spots_profiles_path: Path to SPOTS profiles JSON (from data_converter.py)
        output_path: Path to save training data JSON
        num_samples: Total number of training samples to generate
        records_per_profile: Number of records per profile (auto-calculated if None)
    """
    print(f"Loading SPOTS profiles from: {spots_profiles_path}")
    spots_profiles = load_spots_profiles(spots_profiles_path)
    
    if len(spots_profiles) == 0:
        raise ValueError(f"No profiles found in {spots_profiles_path}")
    
    print(f"Loaded {len(spots_profiles)} SPOTS profiles")
    
    # Calculate records per profile
    if records_per_profile is None:
        records_per_profile = max(1, num_samples // len(spots_profiles))
    
    print(f"Generating {records_per_profile} records per profile...")
    
    # Create dataset with metadata
    metadata = DatasetMetadata(
        num_samples=0,  # Will be updated as records are added
        source='hybrid_big_five',
        description='Hybrid training data using Big Five converted profiles (real personality + synthetic spots/context/timing)',
        user_profiles_source=str(spots_profiles_path),
        records_per_profile=records_per_profile,
        generation_params={
            'num_samples': num_samples,
            'records_per_profile': records_per_profile,
        },
    )
    
    dataset = TrainingDataset(metadata=metadata)
    
    # Generate training records
    record_index = 0
    
    for profile in spots_profiles:
        for _ in range(records_per_profile):
            if record_index >= num_samples:
                break
            
            record = generate_training_record(profile, record_index=record_index)
            dataset.add_record(record)
            record_index += 1
        
        if record_index >= num_samples:
            break
    
    # Trim to exact number if needed
    dataset.records = dataset.records[:num_samples]
    dataset.metadata.num_samples = len(dataset.records)
    
    # Calculate statistics
    dataset.calculate_statistics()
    
    # Validate dataset
    validation_issues = dataset.validate()
    if validation_issues:
        print(f"⚠️  Validation warnings ({len(validation_issues)}):")
        for issue in validation_issues[:10]:  # Show first 10
            print(f"   - {issue}")
        if len(validation_issues) > 10:
            print(f"   ... and {len(validation_issues) - 10} more")
    
    # Save dataset
    dataset.save(output_path)
    
    # Print summary
    stats = dataset.metadata.statistics
    print(f"\n✅ Generated {len(dataset)} hybrid training records")
    print(f"   Saved to: {output_path}")
    print(f"\n📊 Statistics:")
    print(f"   Called: {stats.get('called_percentage', 0):.1f}%")
    print(f"   Positive outcomes: {stats.get('positive_outcome_percentage', 0):.1f}%")
    print(f"   Average calling score: {stats.get('average_calling_score', 0):.4f}")
    print(f"   Average outcome score: {stats.get('average_outcome_score', 0):.4f}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate hybrid training data using Big Five converted profiles',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Step 1: Convert Big Five dataset to SPOTS format
  python scripts/knot_validation/data_converter.py data/raw/big_five.csv --output data/raw/big_five_spots.json
  
  # Step 2: Generate hybrid training data
  python scripts/ml/generate_hybrid_training_data.py \\
    data/raw/big_five_spots.json \\
    --output data/calling_score_training_data_hybrid.json \\
    --num-samples 10000
        """
    )
    
    parser.add_argument(
        'spots_profiles',
        type=Path,
        help='Path to SPOTS profiles JSON (from data_converter.py)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        default=Path('data/calling_score_training_data_hybrid.json'),
        help='Output training data JSON path (default: data/calling_score_training_data_hybrid.json)'
    )
    parser.add_argument(
        '--num-samples',
        type=int,
        default=10000,
        help='Number of training samples to generate (default: 10000)'
    )
    parser.add_argument(
        '--records-per-profile',
        type=int,
        default=None,
        help='Number of records per profile (auto-calculated if not specified)'
    )
    
    args = parser.parse_args()
    
    try:
        generate_hybrid_dataset(
            args.spots_profiles,
            args.output,
            args.num_samples,
            args.records_per_profile,
        )
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)
