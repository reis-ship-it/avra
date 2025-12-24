#!/usr/bin/env python3
"""
Shared Data Model for Full Ecosystem Integration

This module provides shared data structures and utilities for integrating
all SPOTS patents in the full ecosystem simulation.

Date: December 21, 2025
"""

import numpy as np
import json
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from datetime import datetime
import time
import random

# ============================================================================
# SHARED DATA STRUCTURES
# ============================================================================

@dataclass
class UserProfile:
    """
    Unified user profile used across all patents.
    Integrates: 12D personality, expertise, location, history
    
    Key Insight: Core personality dimensions are stable. Convergence happens on
    contextual preferences (events, spots), not core personality traits.
    """
    agent_id: str
    personality_12d: np.ndarray  # 12 dimensions (CORE - stable, differences preserved)
    dimension_confidence: np.ndarray  # 12 confidence scores
    expertise_paths: Dict[str, float]  # 6 paths: exploration, credentials, influence, professional, community, local
    expertise_score: float
    expertise_level: str  # 'none', 'Local', 'City', 'Regional', 'National', 'Global', 'Universal'
    location: Dict[str, float]  # {'lat': float, 'lng': float}
    platform_phase: str  # 'Early', 'Growth', 'Mature'
    category: Optional[str] = None
    
    # Contextual preferences (CONVERGENCE ALLOWED - events, spots, suggestions)
    event_preferences: Dict[str, float] = None  # Category preferences for events
    spot_preferences: Dict[str, float] = None  # Location/spot type preferences
    suggestion_preferences: Dict[str, float] = None  # General suggestion preferences
    
    # History tracking
    conversation_history: List[Dict] = None
    recommendation_history: List[Dict] = None
    event_history: List[Dict] = None
    partnership_history: List[Dict] = None
    revenue_history: List[Dict] = None
    
    # Additional metadata
    created_at: float = None
    last_updated: float = None
    expert_creation_time: Optional[float] = None  # Month when user became expert (None if not expert)
    
    def __post_init__(self):
        """Initialize default values."""
        if self.conversation_history is None:
            self.conversation_history = []
        if self.recommendation_history is None:
            self.recommendation_history = []
        if self.event_history is None:
            self.event_history = []
        if self.partnership_history is None:
            self.partnership_history = []
        if self.revenue_history is None:
            self.revenue_history = []
        if self.created_at is None:
            self.created_at = time.time()
        if self.last_updated is None:
            self.last_updated = time.time()
        # Initialize contextual preferences
        if self.event_preferences is None:
            self.event_preferences = {
                'technology': np.random.uniform(0.0, 1.0),
                'science': np.random.uniform(0.0, 1.0),
                'art': np.random.uniform(0.0, 1.0),
                'business': np.random.uniform(0.0, 1.0),
                'health': np.random.uniform(0.0, 1.0),
            }
        if self.spot_preferences is None:
            self.spot_preferences = {
                'indoor': np.random.uniform(0.0, 1.0),
                'outdoor': np.random.uniform(0.0, 1.0),
                'urban': np.random.uniform(0.0, 1.0),
                'nature': np.random.uniform(0.0, 1.0),
                'social': np.random.uniform(0.0, 1.0),
            }
        if self.suggestion_preferences is None:
            self.suggestion_preferences = {
                'frequency': np.random.uniform(0.0, 1.0),
                'timing': np.random.uniform(0.0, 1.0),
                'format': np.random.uniform(0.0, 1.0),
            }
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization."""
        data = asdict(self)
        data['personality_12d'] = self.personality_12d.tolist()
        data['dimension_confidence'] = self.dimension_confidence.tolist()
        # Ensure preferences are serializable
        if self.event_preferences is None:
            data['event_preferences'] = {}
        if self.spot_preferences is None:
            data['spot_preferences'] = {}
        if self.suggestion_preferences is None:
            data['suggestion_preferences'] = {}
        return data
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'UserProfile':
        """Create from dictionary."""
        data['personality_12d'] = np.array(data['personality_12d'])
        data['dimension_confidence'] = np.array(data['dimension_confidence'])
        return cls(**data)


@dataclass
class Event:
    """
    Unified event structure used across patents.
    Integrates: Multi-entity matching, revenue distribution, expertise tracking
    """
    event_id: str
    host_id: str  # Expert who hosts
    category: str
    location: Dict[str, float]
    event_date: float  # Unix timestamp
    duration_hours: float
    
    # Multi-entity matching (Patent #29)
    entities: List[Dict]  # List of entities (users, businesses, brands, etc.)
    n_way_match: bool = True
    
    # Revenue distribution (Patent #15)
    total_revenue: float = 0.0
    revenue_split: Optional[Dict] = None  # N-way split data
    is_locked: bool = False
    locked_at: Optional[float] = None
    
    # Partnership tracking (Patent #16)
    partnership_id: Optional[str] = None
    exclusivity_checked: bool = False
    
    # Expertise tracking (Patent #13)
    expertise_boost_applied: bool = False
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Event':
        """Create from dictionary."""
        return cls(**data)


@dataclass
class Partnership:
    """
    Unified partnership structure.
    Integrates: Exclusivity enforcement, revenue, expertise boost
    """
    partnership_id: str
    expert_id: str
    partner_id: str  # Business or brand
    partner_type: str  # 'Business' or 'Brand'
    exclusivity_type: str  # 'Full', 'Category', 'Product'
    start_date: float
    end_date: float
    minimum_events: int
    
    # Optional fields
    exclusivity_scope: Optional[str] = None  # Category or product name
    
    # Schedule compliance (Patent #16)
    actual_events: int = 0
    is_on_track: bool = True
    behind_by: int = 0
    
    # Revenue (Patent #15)
    total_revenue: float = 0.0
    
    # Expertise boost (Patent #17)
    expertise_boost_applied: bool = False
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Partnership':
        """Create from dictionary."""
        return cls(**data)


@dataclass
class Recommendation:
    """
    Unified recommendation structure.
    Integrates: 12D personality, fusion, calling score
    """
    recommendation_id: str
    user_id: str
    target_id: str  # Spot, event, or opportunity ID
    target_type: str  # 'spot', 'event', 'opportunity'
    
    # Required scores
    fused_score: float = 0.0
    personalized_score: float = 0.0
    weighted_compatibility: float = 0.0
    calling_score: float = 0.0
    quantum_compatibility: float = 0.0
    
    # Multi-source fusion (Patent #20)
    real_time_score: float = 0.0
    community_score: float = 0.0
    ai2ai_score: float = 0.0
    federated_score: float = 0.0
    
    # 12D compatibility (Patent #19)
    dimension_compatibility: float = 0.0
    energy_compatibility: float = 0.0
    exploration_compatibility: float = 0.0
    
    # Calling score (Patent #22)
    meets_calling_threshold: bool = False  # >= 0.70
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Partnership':
        """Create from dictionary."""
        return cls(**data)


# ============================================================================
# SHARED UTILITIES
# ============================================================================

def quantum_compatibility(profile_a: np.ndarray, profile_b: np.ndarray) -> float:
    """
    Calculate quantum compatibility: C = |⟨ψ_A|ψ_B⟩|²
    Used by: Patent #1, #17, #19, #22
    """
    inner_product = np.abs(np.dot(profile_a, profile_b))
    return inner_product ** 2


def calculate_homogenization_rate(personalities: List[np.ndarray]) -> float:
    """
    Calculate homogenization rate based on average pairwise Euclidean distance.
    Homogenization = 1 - (average_pairwise_distance / max_possible_distance)
    """
    if len(personalities) < 2:
        return 0.0

    personalities_array = np.array(personalities)
    pairwise_distances = []
    for i in range(len(personalities_array)):
        for j in range(i + 1, len(personalities_array)):
            dist = np.linalg.norm(personalities_array[i] - personalities_array[j])
            pairwise_distances.append(dist)

    if len(pairwise_distances) > 0:
        avg_distance = np.mean(pairwise_distances)
        max_possible_distance = np.sqrt(12)  # Max distance in 12D space (0 to 1)
        homogenization = 1.0 - (avg_distance / max_possible_distance)
    else:
        homogenization = 0.0
    return max(0.0, min(1.0, homogenization))


def calculate_expertise_score(expertise_paths: Dict[str, float]) -> float:
    """
    Calculate multi-path expertise score.
    Used by: Patent #13, #17
    Weights: Exploration 40%, Credentials 25%, Influence 20%, Professional 25%, Community 15%, Local 10%
    """
    return (expertise_paths.get('exploration', 0.0) * 0.40 +
           expertise_paths.get('credentials', 0.0) * 0.25 +
           expertise_paths.get('influence', 0.0) * 0.20 +
           expertise_paths.get('professional', 0.0) * 0.25 +
           expertise_paths.get('community', 0.0) * 0.15 +
           expertise_paths.get('local', 0.0) * 0.1)


def get_dynamic_threshold(platform_phase: str, base_threshold: float = 0.7) -> float:
    """
    Get dynamic threshold based on platform phase.
    Used by: Patent #13
    """
    phase_thresholds = {
        'Early': 0.6,
        'Growth': 0.7,
        'Mature': 0.8,
    }
    return phase_thresholds.get(platform_phase, 0.7)


def calculate_location_match(loc1: Dict[str, float], loc2: Dict[str, float]) -> float:
    """
    Calculate location match (0-1 scale).
    Used by: Patent #17, #20, #22
    """
    distance = np.sqrt((loc1['lat'] - loc2['lat'])**2 + 
                      (loc1['lng'] - loc2['lng'])**2) * 111000  # meters
    max_distance = 20000  # 20km max
    return max(0.0, 1.0 - (distance / max_distance))


# ============================================================================
# DATA GENERATION
# ============================================================================

def generate_integrated_user_profile(
    agent_id: str,
    location: Optional[Dict[str, float]] = None,
    platform_phase: str = 'Growth',
    category: Optional[str] = None,
    random_seed: Optional[int] = None
) -> UserProfile:
    """
    Generate a complete user profile for integration testing.
    """
    if random_seed is not None:
        np.random.seed(random_seed)
        random.seed(random_seed)
    
    # Generate 12D personality with MAXIMUM diversity
    # Use very wide distribution to ensure highly diverse initial personalities
    # Beta(0.1, 0.1) creates extremely U-shaped distribution (very extreme values = maximum diversity)
    # This ensures initial homogenization is low (~36%, well below 52% target)
    personality_12d = np.random.beta(0.1, 0.1, 12)  # Extremely extreme - creates maximum diversity
    dimension_confidence = np.random.uniform(0.6, 1.0, 12)
    
    # Generate expertise paths (start moderate to allow growth to thresholds)
    expertise_paths = {
        'exploration': np.random.uniform(0.2, 0.5),  # Start moderate
        'credentials': np.random.uniform(0.1, 0.4),  # Start lower (harder to get)
        'influence': np.random.uniform(0.1, 0.4),  # Start lower
        'professional': np.random.uniform(0.2, 0.5),  # Start moderate
        'community': np.random.uniform(0.2, 0.5),  # Start moderate
        'local': np.random.uniform(0.1, 0.4),  # Start lower
    }
    
    # Calculate expertise score
    expertise_score = calculate_expertise_score(expertise_paths)
    
    # Determine expertise level
    if expertise_score >= 0.8:
        expertise_level = 'Global'
    elif expertise_score >= 0.7:
        expertise_level = 'National'
    elif expertise_score >= 0.6:
        expertise_level = 'Regional'
    elif expertise_score >= 0.5:
        expertise_level = 'City'
    elif expertise_score >= 0.4:
        expertise_level = 'Local'
    else:
        expertise_level = 'none'
    
    # Generate location if not provided
    if location is None:
        location = {
            'lat': np.random.uniform(-90, 90),
            'lng': np.random.uniform(-180, 180),
        }
    
    # Select category if not provided
    if category is None:
        category = np.random.choice(['technology', 'science', 'art', 'business', 'health'])
    
    return UserProfile(
        agent_id=agent_id,
        personality_12d=personality_12d,
        dimension_confidence=dimension_confidence,
        expertise_paths=expertise_paths,
        expertise_score=expertise_score,
        expertise_level=expertise_level,
        location=location,
        platform_phase=platform_phase,
        category=category,
    )


def generate_integrated_event(
    event_id: str,
    host_id: str,
    category: str,
    location: Dict[str, float],
    event_date: float,
    entities: List[Dict],
    total_revenue: float = 0.0,
) -> Event:
    """
    Generate a complete event for integration testing.
    """
    return Event(
        event_id=event_id,
        host_id=host_id,
        category=category,
        location=location,
        event_date=event_date,
        duration_hours=np.random.uniform(2, 8),
        entities=entities,
        n_way_match=True,
        total_revenue=total_revenue,
    )


def generate_integrated_partnership(
    partnership_id: str,
    expert_id: str,
    partner_id: str,
    partner_type: str,
    exclusivity_type: str,
    start_date: float,
    end_date: float,
    minimum_events: int,
    exclusivity_scope: Optional[str] = None,
) -> Partnership:
    """
    Generate a complete partnership for integration testing.
    """
    return Partnership(
        partnership_id=partnership_id,
        expert_id=expert_id,
        partner_id=partner_id,
        partner_type=partner_type,
        exclusivity_type=exclusivity_type,
        exclusivity_scope=exclusivity_scope,
        start_date=start_date,
        end_date=end_date,
        minimum_events=minimum_events,
    )


# ============================================================================
# DATA PERSISTENCE
# ============================================================================

def save_integrated_data(
    users: List[UserProfile],
    events: List[Event],
    partnerships: List[Partnership],
    data_dir: Path
):
    """Save integrated data to JSON files."""
    data_dir.mkdir(parents=True, exist_ok=True)
    
    # Save users
    users_data = [user.to_dict() for user in users]
    with open(data_dir / 'integrated_users.json', 'w') as f:
        json.dump(users_data, f, indent=2)
    
    # Save events
    events_data = [event.to_dict() for event in events]
    with open(data_dir / 'integrated_events.json', 'w') as f:
        json.dump(events_data, f, indent=2)
    
    # Save partnerships
    partnerships_data = [p.to_dict() for p in partnerships]
    with open(data_dir / 'integrated_partnerships.json', 'w') as f:
        json.dump(partnerships_data, f, indent=2)
    
    print(f"✅ Saved integrated data to {data_dir}")


def load_integrated_data(data_dir: Path) -> tuple:
    """Load integrated data from JSON files."""
    with open(data_dir / 'integrated_users.json', 'r') as f:
        users_data = json.load(f)
    users = [UserProfile.from_dict(u) for u in users_data]
    
    with open(data_dir / 'integrated_events.json', 'r') as f:
        events_data = json.load(f)
    events = [Event.from_dict(e) for e in events_data]
    
    with open(data_dir / 'integrated_partnerships.json', 'r') as f:
        partnerships_data = json.load(f)
    partnerships = [Partnership.from_dict(p) for p in partnerships_data]
    
    return users, events, partnerships


# ============================================================================
# HYBRID HOMOGENIZATION PREVENTION FUNCTIONS
# ============================================================================

def generate_diverse_state(user: UserProfile, all_users: List[UserProfile]) -> np.ndarray:
    """Generate a diverse personality state (opposite of average)."""
    if len(all_users) == 0:
        return user.personality_12d.copy()
    
    avg_personality = np.mean([u.personality_12d for u in all_users], axis=0)
    # Opposite of average + random variation
    diverse_state = np.clip(
        1.0 - avg_personality + np.random.uniform(-0.2, 0.2, 12),
        0.0, 1.0
    )
    return diverse_state


def generate_opposite_state(user: UserProfile, all_users: List[UserProfile]) -> np.ndarray:
    """Generate opposite personality state (maximum diversity)."""
    if len(all_users) == 0:
        return user.personality_12d.copy()
    
    avg_personality = np.mean([u.personality_12d for u in all_users], axis=0)
    # Opposite of average + large random variation
    opposite_state = np.clip(
        1.0 - avg_personality + np.random.uniform(-0.3, 0.3, 12),
        0.0, 1.0
    )
    return opposite_state


def quantum_interference_learning(
    user_personality: np.ndarray,
    partner_personality: np.ndarray,
    compatibility: float
) -> np.ndarray:
    """
    Quantum interference learning: Learn from differences to inform preferences.
    
    Key Insight: Similar partners have differences that create constructive interference
    when learning from differences (preferences/dislikes), destructive when learning similarities.
    
    |ψ_final⟩ = |ψ_A⟩ + |ψ_B⟩
    """
    difference_vector = partner_personality - user_personality
    
    # Learning wave functions (complex)
    learning_wave_a = np.exp(1j * np.pi * user_personality)
    learning_wave_b = np.exp(1j * np.pi * partner_personality)
    
    # Interference pattern
    interference = learning_wave_a + learning_wave_b
    interference_amplitude = np.abs(interference)
    interference_phase = np.angle(interference)
    
    if compatibility >= 0.3:
        # Similar partners: Learn from DIFFERENCES (preferences/dislikes)
        # Constructive interference on differences (amplify preference learning)
        difference_mask = np.abs(difference_vector) >= 0.03  # Even lower threshold: 0.03 (more dimensions considered different)
        learning_strength = interference_amplitude * 0.03 * (1.0 - compatibility)  # Increased from 0.02, even stronger
        # Learn differences: Move AWAY from partner in different dimensions (diversity)
        difference_learning = -difference_vector * difference_mask  # Opposite direction
        evolution = user_personality + learning_strength * difference_learning
    else:
        # Diverse partners: Learn from similarities (safe convergence)
        # Constructive interference on similarities (amplify shared learning)
        similarity_mask = np.abs(difference_vector) < 0.03  # Even lower threshold: 0.03
        learning_strength = interference_amplitude * 0.003 * compatibility  # Reduced from 0.005, even weaker
        similarity_learning = difference_vector * similarity_mask  # Same direction
        evolution = user_personality + learning_strength * similarity_learning
    
    return np.clip(evolution, 0.0, 1.0)


def quantum_measurement_learning(
    user_personality: np.ndarray,
    partner_personality: np.ndarray,
    all_users: List[UserProfile]
) -> np.ndarray:
    """
    Quantum measurement: Collapse to diverse states (inverted Born rule).
    P(diverse) > P(convergent)
    """
    # Create temporary user for diverse state generation
    temp_user = UserProfile(
        agent_id='temp',
        personality_12d=user_personality,
        dimension_confidence=np.ones(12),
        expertise_paths={},
        expertise_score=0.0,
        expertise_level='none',
        location={'lat': 0.0, 'lng': 0.0},
        platform_phase='Growth'
    )
    
    # Possible measurement outcomes (diverse states)
    measurement_states = [
        user_personality.copy(),  # Current state
        generate_diverse_state(temp_user, all_users),  # Diverse state 1
        generate_opposite_state(temp_user, all_users),  # Diverse state 2
    ]
    
    # Measurement probabilities (Born rule with inversion)
    probabilities = []
    for state in measurement_states:
        overlap = quantum_compatibility(user_personality, state)
        # Invert: Lower compatibility = higher probability (diverse preferred)
        probability = (1.0 - overlap) ** 2  # Born rule: |⟨n|ψ⟩|²
        probabilities.append(probability)
    
    # Normalize probabilities
    probabilities = np.array(probabilities)
    if np.sum(probabilities) > 0:
        probabilities = probabilities / np.sum(probabilities)
    else:
        probabilities = np.array([1.0, 0.0, 0.0])  # Default to current state
    
    # Quantum measurement (collapse to state)
    collapsed_state_idx = np.random.choice(len(measurement_states), p=probabilities)
    collapsed_state = measurement_states[collapsed_state_idx]
    
    # Learning from collapsed state (diverse)
    learning_strength = 0.005  # Small learning
    evolution = user_personality + learning_strength * (collapsed_state - user_personality)
    
    return np.clip(evolution, 0.0, 1.0)


def apply_time_decay_learning(
    user_personality: np.ndarray,
    original_personality: np.ndarray,
    days_since_join: int,
    decay_rate: float = 0.003  # Increased from 0.002 (even faster decay)
) -> np.ndarray:
    """
    Time-decay learning: Learning fades over time.
    Returns user toward original personality gradually.
    """
    # Decay factor (exponential decay)
    decay_factor = np.exp(-decay_rate * days_since_join)
    
    # Apply decay to learned changes
    learned_change = user_personality - original_personality
    decayed_change = learned_change * decay_factor
    
    # New personality (decayed toward original)
    new_personality = original_personality + decayed_change
    
    return np.clip(new_personality, 0.0, 1.0)


def bidirectional_learning(
    user_personality: np.ndarray,
    partner_personality: np.ndarray,
    compatibility: float
) -> np.ndarray:
    """
    Bidirectional learning: Learn from differences to inform preferences/dislikes.
    
    Key Insight: Similar partners have differences that inform preferences.
    - Pull: Learn shared traits (safe convergence)
    - Push: Learn differences (preferences/dislikes maintain diversity)
    """
    difference_vector = partner_personality - user_personality
    
    # Pull: Learn shared traits (convergence on similarities)
    # Only pull on dimensions where they're similar (small differences)
    similarity_mask = np.abs(difference_vector) < 0.03  # Even lower threshold: 0.03
    pull_strength = compatibility * 0.003  # Reduced from 0.005, even weaker pull
    pull_vector = difference_vector * similarity_mask  # Only similar dimensions
    
    # Push: Learn differences (preferences/dislikes maintain diversity)
    # Push on dimensions where they differ (large differences)
    difference_mask = np.abs(difference_vector) >= 0.03  # Even lower threshold: 0.03
    push_strength = (1.0 - compatibility) * 0.02  # Increased from 0.015, even stronger push
    push_vector = -difference_vector * difference_mask  # Opposite direction (diversity)
    
    # Combined evolution (balance: learn similarities, differentiate on differences)
    evolution = user_personality + pull_strength * pull_vector + push_strength * push_vector
    
    return np.clip(evolution, 0.0, 1.0)


def diversity_preserving_learning(
    user_personality: np.ndarray,
    partner_personality: np.ndarray,
    compatibility: float,
    threshold: float = 0.3
) -> np.ndarray:
    """
    Diversity-preserving learning: Learn from differences, not similarities.
    
    Key Insight: Learning from similar partners can be diverse if we learn from
    the DIFFERENCES. The differences inform preferences and dislikes, maintaining diversity.
    
    - High compatibility (similar): Learn from differences (what they DON'T share)
    - Low compatibility (diverse): Learn from similarities (what they DO share)
    """
    # Calculate difference vector (what makes them different)
    difference_vector = partner_personality - user_personality
    
    if compatibility >= threshold:
        # Similar partners: Learn from DIFFERENCES (maintains diversity)
        # Focus on what they DON'T share - this informs preferences/dislikes
        # Invert learning: Move AWAY from partner in dimensions where they differ
        # This creates diversity through preference differentiation
        learning_strength = 0.03 * (1.0 - compatibility)  # Increased from 0.02, even stronger for larger differences
        # Learn differences: Move in opposite direction of difference (diversity)
        evolution = user_personality - learning_strength * difference_vector
    else:
        # Diverse partners: Learn from similarities (what they DO share)
        # Focus on what they share - this is safe learning
        learning_strength = 0.003 * compatibility  # Reduced from 0.005, even weaker learning
        # Learn similarities: Move toward shared traits (safe convergence)
        evolution = user_personality + learning_strength * difference_vector
    
    return np.clip(evolution, 0.0, 1.0)


def quantum_superposition_learning(
    user_personality: np.ndarray,
    all_users: List[UserProfile]
) -> np.ndarray:
    """
    Quantum superposition: Multiple states, collapse to diverse.
    """
    # Create temporary user for diverse state generation
    temp_user = UserProfile(
        agent_id='temp',
        personality_12d=user_personality,
        dimension_confidence=np.ones(12),
        expertise_paths={},
        expertise_score=0.0,
        expertise_level='none',
        location={'lat': 0.0, 'lng': 0.0},
        platform_phase='Growth'
    )
    
    # Superposition states
    current_state = user_personality.copy()
    diverse_state_1 = generate_diverse_state(temp_user, all_users)
    diverse_state_2 = generate_opposite_state(temp_user, all_users)
    
    superposition_states = [current_state, diverse_state_1, diverse_state_2]
    
    # Superposition amplitudes (probabilities)
    # Higher probability for diverse states
    amplitudes = [0.5, 0.3, 0.2]  # Current, diverse 1, diverse 2
    
    # Quantum measurement (collapse to state)
    collapsed_state_idx = np.random.choice(len(superposition_states), p=amplitudes)
    collapsed_state = superposition_states[collapsed_state_idx]
    
    # Learning from collapsed state
    learning_strength = 0.005
    evolution = user_personality + learning_strength * (collapsed_state - user_personality)
    
    return np.clip(evolution, 0.0, 1.0)


def create_personality_anchors(users: List[UserProfile], anchor_percentage: float = 0.12) -> List[UserProfile]:
    """
    Create personality anchors (permanent diversity).
    12% of users are anchors (never evolve).
    """
    if len(users) == 0:
        return []
    
    num_anchors = max(1, int(len(users) * anchor_percentage))
    anchors = random.sample(users, min(num_anchors, len(users)))
    
    for anchor in anchors:
        anchor._is_anchor = True
        if not hasattr(anchor, '_original_personality'):
            anchor._original_personality = anchor.personality_12d.copy()
        anchor._anchor_created = True
    
    return anchors


def is_anchor(user: UserProfile) -> bool:
    """Check if user is an anchor."""
    return hasattr(user, '_is_anchor') and user._is_anchor


def hybrid_learning_function(
    user: UserProfile,
    partner: UserProfile,
    all_users: List[UserProfile],
    agent_join_times: Dict[str, int],
    current_month: int,
    current_homogenization: float
) -> tuple:
    """
    Hybrid learning: Convergence on shared preferences (events/spots), preserve core personality differences.
    
    Key Insight:
    - Core personality dimensions: STABLE (differences preserved, no convergence)
    - Contextual preferences (events/spots): CONVERGENCE ALLOWED (learn from similarities)
    - Differences are good: Preserve them in core personality
    """
    # Skip if anchor
    if is_anchor(user):
        return user.personality_12d.copy(), user.event_preferences.copy(), user.spot_preferences.copy(), user.suggestion_preferences.copy()
    
    # Calculate compatibility
    compatibility = quantum_compatibility(user.personality_12d, partner.personality_12d)
    
    # Ensure original personality exists
    if not hasattr(user, '_original_personality'):
        user._original_personality = user.personality_12d.copy()
    
    # Calculate days since join
    join_month = agent_join_times.get(user.agent_id, 0)
    days_since_join = (current_month - join_month) * 30
    
    # CORE PERSONALITY: COMPLETELY STABLE - No learning, no decay, preserve differences
    # Differences are good - preserve them completely
    # Core personality dimensions should NOT change (only preferences converge)
    new_personality = user.personality_12d.copy()  # No change to core personality
    
    # CONTEXTUAL PREFERENCES: Convergence allowed on similarities
    # Learn from shared preferences (events, spots, suggestions)
    new_event_preferences = user.event_preferences.copy()
    new_spot_preferences = user.spot_preferences.copy()
    new_suggestion_preferences = user.suggestion_preferences.copy()
    
    if compatibility >= 0.3:  # Similar users: Converge on shared preferences
        # Learn from shared event preferences
        for category in new_event_preferences:
            if category in partner.event_preferences:
                # Converge on shared preferences (move toward partner's preference)
                shared_preference = (user.event_preferences[category] + partner.event_preferences[category]) / 2
                learning_strength = 0.01 * compatibility  # Stronger for more similar users
                new_event_preferences[category] = (
                    user.event_preferences[category] * (1 - learning_strength) +
                    shared_preference * learning_strength
                )
        
        # Learn from shared spot preferences
        for spot_type in new_spot_preferences:
            if spot_type in partner.spot_preferences:
                shared_preference = (user.spot_preferences[spot_type] + partner.spot_preferences[spot_type]) / 2
                learning_strength = 0.01 * compatibility
                new_spot_preferences[spot_type] = (
                    user.spot_preferences[spot_type] * (1 - learning_strength) +
                    shared_preference * learning_strength
                )
        
        # Learn from shared suggestion preferences
        for pref_type in new_suggestion_preferences:
            if pref_type in partner.suggestion_preferences:
                shared_preference = (user.suggestion_preferences[pref_type] + partner.suggestion_preferences[pref_type]) / 2
                learning_strength = 0.01 * compatibility
                new_suggestion_preferences[pref_type] = (
                    user.suggestion_preferences[pref_type] * (1 - learning_strength) +
                    shared_preference * learning_strength
                )
    
    # Apply drift limit to core personality (6% max change from original)
    drift = np.abs(new_personality - user._original_personality)
    max_drift = 0.06  # 6% max drift
    
    if np.any(drift > max_drift):
        # Constrain to drift limit
        for dim in range(12):
            if drift[dim] > max_drift:
                direction = 1 if new_personality[dim] > user._original_personality[dim] else -1
                new_personality[dim] = user._original_personality[dim] + (max_drift * direction)
    
    return (
        np.clip(new_personality, 0.0, 1.0),
        {k: np.clip(v, 0.0, 1.0) for k, v in new_event_preferences.items()},
        {k: np.clip(v, 0.0, 1.0) for k, v in new_spot_preferences.items()},
        {k: np.clip(v, 0.0, 1.0) for k, v in new_suggestion_preferences.items()}
    )
    
    # Layer 1: Quantum Interference Learning (Primary)
    evolution_interference = quantum_interference_learning(
        user.personality_12d,
        partner.personality_12d,
        compatibility
    )
    
    # Layer 2: Quantum Measurement Learning (Secondary)
    evolution_measurement = quantum_measurement_learning(
        user.personality_12d,
        partner.personality_12d,
        all_users
    )
    
    # Layer 3: Time-Decay Learning (Long-term stability)
    evolution_decay = apply_time_decay_learning(
        user.personality_12d,
        user._original_personality,
        days_since_join
    )
    
    # Layer 4: Bidirectional Learning (Balance)
    evolution_bidirectional = bidirectional_learning(
        user.personality_12d,
        partner.personality_12d,
        compatibility
    )
    
    # Layer 5: Diversity-Preserving Learning (Base)
    evolution_diversity = diversity_preserving_learning(
        user.personality_12d,
        partner.personality_12d,
        compatibility
    )
    
    # Layer 6: Quantum Superposition Learning (Multiple states)
    evolution_superposition = quantum_superposition_learning(
        user.personality_12d,
        all_users
    )
    
    # Weighted combination of all layers
    # Updated weights: Emphasize difference-based learning (preferences/dislikes)
    # Key insight: Learning from similar partners can be diverse if we learn from differences
    # More aggressive: Increase difference learning, decrease similarity learning
    weights = {
        'interference': 0.45,      # Increased from 0.40 (quantum interference - learns from differences)
        'measurement': 0.10,       # Reduced from 0.15 (quantum measurement)
        'decay': 0.20,             # Increased from 0.15 (faster time-decay)
        'bidirectional': 0.20,     # Maintained (learn similarities, differentiate differences)
        'diversity': 0.04,        # Reduced from 0.08 (base mechanism)
        'superposition': 0.01,    # Reduced from 0.02 (multiple states)
    }
    
    # Combine evolutions
    final_evolution = (
        weights['interference'] * evolution_interference +
        weights['measurement'] * evolution_measurement +
        weights['decay'] * evolution_decay +
        weights['bidirectional'] * evolution_bidirectional +
        weights['diversity'] * evolution_diversity +
        weights['superposition'] * evolution_superposition
    )
    
    # Apply drift limit (6% max change from original)
    drift = np.abs(final_evolution - user._original_personality)
    max_drift = 0.06  # 6% max drift
    
    if np.any(drift > max_drift):
        # Constrain to drift limit
        for dim in range(12):
            if drift[dim] > max_drift:
                direction = 1 if final_evolution[dim] > user._original_personality[dim] else -1
                final_evolution[dim] = user._original_personality[dim] + (max_drift * direction)
    
    return np.clip(final_evolution, 0.0, 1.0)

