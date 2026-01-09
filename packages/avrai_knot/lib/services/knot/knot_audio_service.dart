// Knot Audio Service
// 
// Generates audio from knot topology (especially loading sounds)
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 7: Audio & Privacy

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:avrai_core/models/personality_knot.dart';
import 'package:avrai_knot/models/knot/musical_pattern.dart';
import 'package:avrai_knot/models/knot/knot_fabric.dart';

/// Service for generating and playing audio from knot topology
/// 
/// **Audio Playback:** Uses audioplayers for actual audio playback
/// **Note:** Audio synthesis from frequencies requires additional work.
/// For now, uses a simplified approach with tone generation.
class KnotAudioService {
  static const String _logName = 'KnotAudioService';

  // Musical parameters
  static const double _baseFrequency = 220.0; // A3 note
  static const double _frequencyRange = 880.0; // 4 octaves
  static const double _noteDuration = 0.2; // 200ms per note
  static const double _loadingSoundDuration = 3.0; // 3 seconds
  static const double _fabricHarmonyDuration = 10.0; // 10 seconds for fabric harmony

  // Audio player
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  File? _currentAudioFile; // Track current temp file for cleanup
  
  // Audio synthesis parameters
  static const int _sampleRate = 44100; // CD quality
  static const int _bitsPerSample = 16;
  static const int _numChannels = 1; // Mono

  AudioPlayer? _getOrCreateAudioPlayer() {
    if (_audioPlayer != null) return _audioPlayer;
    try {
      _audioPlayer = AudioPlayer();
      return _audioPlayer;
    } catch (e, stackTrace) {
      // In unit-test contexts the audioplayers platform implementation is not
      // available (MissingPluginException). This service still supports
      // generating musical patterns without playback.
      developer.log(
        'AudioPlayer not available; playback disabled',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Generate loading sound from user's knot
  /// 
  /// Converts knot structure to musical pattern suitable for loading sounds
  Future<AudioSequence> generateKnotLoadingSound(
    PersonalityKnot knot,
  ) async {
    developer.log(
      'Generating loading sound from knot',
      name: _logName,
    );

    // Convert knot structure to musical pattern
    final musicalPattern = _knotToMusicalPattern(knot);

    return AudioSequence(
      notes: musicalPattern.notes,
      rhythm: musicalPattern.rhythm,
      harmony: musicalPattern.harmony,
      duration: _loadingSoundDuration,
      loop: true,
    );
  }

  /// Generate harmony from knot fabric (community/club weave)
  /// 
  /// Converts a multi-strand braid fabric into polyphonic harmony where:
  /// - Each strand (user knot) = a voice/harmonic
  /// - Fabric invariants = overall harmony, rhythm, and stability
  /// - All voices play simultaneously = rich community sound
  /// 
  /// **Algorithm:**
  /// 1. Each user knot → a voice (set of notes)
  /// 2. Fabric polynomials → chord progressions
  /// 3. Fabric density → rhythm/tempo
  /// 4. Fabric stability → harmony quality (consonant vs dissonant)
  /// 5. Mix all voices into polyphonic harmony
  Future<AudioSequence> generateFabricHarmony(KnotFabric fabric) async {
    developer.log(
      'Generating fabric harmony from ${fabric.userCount} user knots',
      name: _logName,
    );

    try {
      // Step 1: Convert each strand (user knot) to a voice
      final voices = <List<MusicalNote>>[];
      for (final userKnot in fabric.userKnots) {
        final pattern = _knotToMusicalPattern(userKnot);
        voices.add(pattern.notes);
      }

      // Step 2: Calculate fabric-level harmony from invariants
      final fabricHarmony = _calculateFabricHarmony(
        jonesPoly: fabric.invariants.jonesPolynomial.coefficients,
        alexanderPoly: fabric.invariants.alexanderPolynomial.coefficients,
        stability: fabric.invariants.stability,
      );

      // Step 3: Calculate rhythm from fabric density
      final rhythm = _calculateFabricRhythm(fabric.invariants.density);

      // Step 4: Mix all voices into polyphonic harmony
      final mixedNotes = _mixVoicesIntoHarmony(
        voices: voices,
        fabricHarmony: fabricHarmony,
        stability: fabric.invariants.stability,
      );

      developer.log(
        '✅ Generated fabric harmony: ${mixedNotes.length} notes, '
        '${voices.length} voices, ${rhythm.toStringAsFixed(1)}BPM',
        name: _logName,
      );

      return AudioSequence(
        notes: mixedNotes,
        rhythm: rhythm,
        harmony: fabricHarmony,
        duration: _fabricHarmonyDuration,
        loop: true,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to generate fabric harmony: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      // Fallback to single knot pattern if fabric conversion fails
      if (fabric.userKnots.isNotEmpty) {
        return generateKnotLoadingSound(fabric.userKnots.first);
      }
      rethrow;
    }
  }

  /// Play fabric harmony (community/club weave sound)
  /// 
  /// Generates polyphonic harmony from knot fabric and plays it.
  Future<void> playFabricHarmony(KnotFabric fabric) async {
    if (_isPlaying) {
      developer.log('Audio already playing, skipping', name: _logName);
      return;
    }

    developer.log(
      'Playing fabric harmony from ${fabric.userCount} user knots',
      name: _logName,
    );

    try {
      _isPlaying = true;

      // Generate fabric harmony
      final audioSequence = await generateFabricHarmony(fabric);

      // Generate audio data (sine waves from frequencies)
      final audioSamples = await _synthesizeAudio(audioSequence);

      // Encode as WAV file
      final wavBytes = _encodeWav(audioSamples);

      // Save to temporary file
      final tempFile = await _saveToTempFile(wavBytes);

      // Play using audioplayers
      final player = _getOrCreateAudioPlayer();
      if (player != null && tempFile != null) {
        // Clean up previous audio file if any
        await _cleanupAudioFile();
        _currentAudioFile = tempFile;

        // Set release mode for looping
        if (audioSequence.loop) {
          await player.setReleaseMode(ReleaseMode.loop);
        } else {
          await player.setReleaseMode(ReleaseMode.release);
        }

        // Play the audio file
        await player.play(DeviceFileSource(tempFile.path));

        developer.log(
          '✅ Playing fabric harmony: ${audioSequence.notes.length} notes, '
          '${audioSequence.rhythm.toStringAsFixed(1)}BPM, '
          '${(wavBytes.length / 1024).toStringAsFixed(1)}KB, '
          'loop=${audioSequence.loop}',
          name: _logName,
        );
      } else {
        developer.log(
          '⚠️ Audio player not available or temp file creation failed',
          name: _logName,
        );
        _isPlaying = false;
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to play fabric harmony: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
    } finally {
      // Note: Don't set _isPlaying = false here - let stopAudio() handle it
      // The audio will continue playing until stopAudio() is called
    }
  }

  /// Convert knot to musical pattern
  /// 
  /// **Algorithm:**
  /// - Each crossing = musical note
  /// - Crossing number determines frequency
  /// - Writhe determines rhythm
  /// - Polynomial coefficients determine harmony
  MusicalPattern _knotToMusicalPattern(PersonalityKnot knot) {
    final notes = <MusicalNote>[];

    // Extract knot properties
    final crossingNumber = knot.invariants.crossingNumber;
    final writhe = knot.invariants.writhe;
    final jonesPoly = knot.invariants.jonesPolynomial;
    final alexanderPoly = knot.invariants.alexanderPolynomial;

    // Generate notes from crossings
    // Each crossing contributes a note
    for (int i = 0; i < crossingNumber.clamp(0, 20); i++) {
      // Frequency based on crossing position and polynomial coefficients
      final frequency = _calculateNoteFrequency(
        crossingIndex: i,
        totalCrossings: crossingNumber,
        jonesCoeff: jonesPoly.isNotEmpty ? jonesPoly[i % jonesPoly.length] : 0.0,
        alexanderCoeff: alexanderPoly.isNotEmpty
            ? alexanderPoly[i % alexanderPoly.length]
            : 0.0,
      );

      // Duration based on writhe (more writhe = faster rhythm)
      final duration = _calculateNoteDuration(writhe);

      // Volume based on polynomial magnitude
      final volume = _calculateNoteVolume(
        jonesCoeff: jonesPoly.isNotEmpty ? jonesPoly[i % jonesPoly.length] : 0.0,
      );

      notes.add(MusicalNote(
        frequency: frequency,
        duration: duration,
        volume: volume,
      ));
    }

    // Rhythm based on writhe (beats per minute)
    final rhythm = _calculateRhythm(writhe);

    // Harmony from polynomial coefficients
    final harmony = _calculateHarmony(jonesPoly, alexanderPoly);

    return MusicalPattern(
      notes: notes,
      rhythm: rhythm,
      harmony: harmony,
      duration: _loadingSoundDuration,
      loop: true,
    );
  }

  /// Calculate note frequency from knot properties
  /// 
  /// Uses polynomial coefficients to determine pitch
  double _calculateNoteFrequency({
    required int crossingIndex,
    required int totalCrossings,
    required double jonesCoeff,
    required double alexanderCoeff,
  }) {
    // Base frequency with crossing-based variation
    final crossingVariation = (crossingIndex / totalCrossings.clamp(1, 20)) *
        _frequencyRange;

    // Polynomial-based pitch adjustment
    final polyAdjustment = (jonesCoeff + alexanderCoeff) * 100.0;

    // Final frequency
    final frequency = (_baseFrequency + crossingVariation + polyAdjustment)
        .clamp(110.0, 2000.0); // A2 to B6 range

    return frequency;
  }

  /// Calculate note duration from writhe
  /// 
  /// Higher writhe = faster rhythm (shorter notes)
  double _calculateNoteDuration(int writhe) {
    // Base duration with writhe adjustment
    final writheFactor = (writhe.abs() / 10.0).clamp(0.0, 1.0);
    final duration = _noteDuration * (1.0 - writheFactor * 0.5);

    return duration.clamp(0.1, 0.5);
  }

  /// Calculate note volume from polynomial coefficient
  /// 
  /// Larger coefficients = louder notes
  double _calculateNoteVolume({required double jonesCoeff}) {
    final magnitude = jonesCoeff.abs();
    return (0.3 + magnitude * 0.7).clamp(0.1, 1.0);
  }

  /// Calculate rhythm (beats per minute) from writhe
  /// 
  /// Higher writhe = faster tempo
  double _calculateRhythm(int writhe) {
    const baseBPM = 120.0; // Base tempo
    final writheAdjustment = writhe.abs() * 5.0; // 5 BPM per writhe unit
    return (baseBPM + writheAdjustment).clamp(60.0, 180.0);
  }

  /// Calculate harmony (chord progression) from polynomials
  /// 
  /// Uses polynomial coefficients to determine chord frequencies
  List<double> _calculateHarmony(
    List<double> jonesPoly,
    List<double> alexanderPoly,
  ) {
    final harmony = <double>[];

    // Use first few coefficients to create chord
    final maxCoeffs = math.min(3, math.max(jonesPoly.length, alexanderPoly.length));

    for (int i = 0; i < maxCoeffs; i++) {
      final jonesCoeff = i < jonesPoly.length ? jonesPoly[i] : 0.0;
      final alexanderCoeff = i < alexanderPoly.length ? alexanderPoly[i] : 0.0;

      // Chord frequency from coefficients
      final chordFreq = _baseFrequency * (1.0 + (jonesCoeff + alexanderCoeff) * 0.5);
      harmony.add(chordFreq.clamp(110.0, 2000.0));
    }

    // If no coefficients, use default chord
    if (harmony.isEmpty) {
      harmony.addAll([
        _baseFrequency,
        _baseFrequency * 1.25,
        _baseFrequency * 1.5
      ]);
    }

    return harmony;
  }

  /// Calculate fabric-level harmony from fabric invariants
  /// 
  /// Uses fabric polynomials and stability to create richer chord progressions
  /// that represent the community's overall harmonic structure.
  List<double> _calculateFabricHarmony({
    required List<double> jonesPoly,
    required List<double> alexanderPoly,
    required double stability,
  }) {
    final harmony = <double>[];

    // Use more coefficients for fabric (richer harmony)
    final maxCoeffs = math.min(5, math.max(jonesPoly.length, alexanderPoly.length));

    for (int i = 0; i < maxCoeffs; i++) {
      final jonesCoeff = i < jonesPoly.length ? jonesPoly[i] : 0.0;
      final alexanderCoeff = i < alexanderPoly.length ? alexanderPoly[i] : 0.0;

      // Base chord frequency from coefficients
      var chordFreq = _baseFrequency * (1.0 + (jonesCoeff + alexanderCoeff) * 0.5);

      // Stability adjustment: high stability = consonant intervals
      // Low stability = more dissonant intervals
      if (stability > 0.7) {
        // High stability: use consonant intervals (major thirds, perfect fifths)
        final intervalRatios = [1.0, 1.25, 1.5, 1.875, 2.0]; // Root, major third, fifth, major seventh, octave
        if (i < intervalRatios.length) {
          chordFreq = _baseFrequency * intervalRatios[i];
        }
      } else if (stability < 0.3) {
        // Low stability: use more dissonant intervals
        final intervalRatios = [1.0, 1.2, 1.4, 1.7, 1.9]; // More dissonant
        if (i < intervalRatios.length) {
          chordFreq = _baseFrequency * intervalRatios[i];
        }
      }

      harmony.add(chordFreq.clamp(110.0, 2000.0));
    }

    // If no coefficients, use default chord based on stability
    if (harmony.isEmpty) {
      if (stability > 0.7) {
        // Consonant major chord
        harmony.addAll([
          _baseFrequency, // Root
          _baseFrequency * 1.25, // Major third
          _baseFrequency * 1.5, // Perfect fifth
        ]);
      } else if (stability < 0.3) {
        // Dissonant chord
        harmony.addAll([
          _baseFrequency, // Root
          _baseFrequency * 1.2, // Minor third
          _baseFrequency * 1.4, // Tritone
        ]);
      } else {
        // Neutral chord
        harmony.addAll([
          _baseFrequency,
          _baseFrequency * 1.25,
          _baseFrequency * 1.5
        ]);
      }
    }

    return harmony;
  }

  /// Calculate rhythm from fabric density
  /// 
  /// Higher density (more crossings per strand) = faster, more complex rhythm
  double _calculateFabricRhythm(double density) {
    const baseBPM = 100.0; // Base tempo for fabric
    // Density ranges from 0.0 to ~10.0 (crossings per strand)
    // Higher density = faster tempo
    final densityAdjustment = density * 20.0; // 20 BPM per density unit
    return (baseBPM + densityAdjustment).clamp(60.0, 200.0);
  }

  /// Mix multiple voices (strands) into polyphonic harmony
  /// 
  /// Combines notes from all user knots into a single harmonious sequence.
  /// Each voice plays simultaneously, creating rich polyphonic texture.
  List<MusicalNote> _mixVoicesIntoHarmony({
    required List<List<MusicalNote>> voices,
    required List<double> fabricHarmony,
    required double stability,
  }) {
    if (voices.isEmpty) {
      return [];
    }

    // Find the maximum number of notes across all voices
    final maxNotes = voices.fold<int>(
      0,
      (max, voice) => math.max(max, voice.length),
    );

    // Mix voices: each position gets notes from all voices
    final mixedNotes = <MusicalNote>[];

    for (int noteIndex = 0; noteIndex < maxNotes; noteIndex++) {
      // Collect notes from all voices at this position
      final notesAtPosition = <MusicalNote>[];

      for (final voice in voices) {
        if (noteIndex < voice.length) {
          notesAtPosition.add(voice[noteIndex]);
        }
      }

      if (notesAtPosition.isEmpty) continue;

      // Mix notes: average frequency, sum durations, weighted volume
      var totalFrequency = 0.0;
      var totalDuration = 0.0;
      var totalVolume = 0.0;
      var count = 0;

      for (final note in notesAtPosition) {
        totalFrequency += note.frequency;
        totalDuration += note.duration;
        totalVolume += note.volume;
        count++;
      }

      // Calculate mixed note properties
      final mixedFreq = totalFrequency / count;
      final mixedDuration = totalDuration / count;
      
      // Volume: stability affects how voices blend
      // High stability = voices blend smoothly (lower volume per voice)
      // Low stability = voices stand out more (higher volume per voice)
      final volumeMultiplier = stability > 0.7 ? 0.6 : 0.8;
      final mixedVolume = (totalVolume / count * volumeMultiplier).clamp(0.1, 1.0);

      // Add fabric harmony frequencies as additional notes (chord tones)
      for (var i = 0; i < fabricHarmony.length && i < 3; i++) {
        final harmonyFreq = fabricHarmony[i];
        
        // Only add harmony note if it's different enough from mixed frequency
        if ((harmonyFreq - mixedFreq).abs() > 50.0) {
          mixedNotes.add(MusicalNote(
            frequency: harmonyFreq,
            duration: mixedDuration * 1.5, // Harmony notes last longer
            volume: mixedVolume * 0.4, // Lower volume for harmony
          ));
        }
      }

      // Add the main mixed note
      mixedNotes.add(MusicalNote(
        frequency: mixedFreq,
        duration: mixedDuration,
        volume: mixedVolume,
      ));
    }

    // Limit total notes to prevent overwhelming audio
    final maxTotalNotes = 50;
    if (mixedNotes.length > maxTotalNotes) {
      // Take evenly spaced notes
      final step = mixedNotes.length / maxTotalNotes;
      final sampledNotes = <MusicalNote>[];
      for (var i = 0; i < maxTotalNotes; i++) {
        final index = (i * step).round();
        if (index < mixedNotes.length) {
          sampledNotes.add(mixedNotes[index]);
        }
      }
      return sampledNotes;
    }

    return mixedNotes;
  }

  /// Play loading sound from knot
  /// 
  /// Generates audio from knot topology and plays it using audioplayers.
  /// Audio is synthesized from frequencies using sine waves and saved to a temporary WAV file.
  Future<void> playKnotLoadingSound(PersonalityKnot knot) async {
    if (_isPlaying) {
      developer.log('Audio already playing, skipping', name: _logName);
      return;
    }

    developer.log(
      'Playing loading sound from knot',
      name: _logName,
    );

    try {
      _isPlaying = true;

      // Generate musical pattern
      final musicalPattern = _knotToMusicalPattern(knot);
      
      // Create audio sequence
      final audioSequence = AudioSequence(
        notes: musicalPattern.notes,
        rhythm: musicalPattern.rhythm,
        harmony: musicalPattern.harmony,
        duration: _loadingSoundDuration,
        loop: true,
      );

      // Generate audio data (sine waves from frequencies)
      final audioSamples = await _synthesizeAudio(audioSequence);
      
      // Encode as WAV file
      final wavBytes = _encodeWav(audioSamples);
      
      // Save to temporary file
      final tempFile = await _saveToTempFile(wavBytes);
      
      // Play using audioplayers
      final player = _getOrCreateAudioPlayer();
      if (player != null && tempFile != null) {
        // Clean up previous audio file if any
        await _cleanupAudioFile();
        _currentAudioFile = tempFile;
        
        // Set release mode for looping
        if (audioSequence.loop) {
          await player.setReleaseMode(ReleaseMode.loop);
        } else {
          await player.setReleaseMode(ReleaseMode.release);
        }
        
        // Play the audio file
        await player.play(DeviceFileSource(tempFile.path));
        
        developer.log(
          '✅ Playing knot audio: ${audioSequence.notes.length} notes, '
          '${audioSequence.rhythm.toStringAsFixed(1)}BPM, '
          '${(wavBytes.length / 1024).toStringAsFixed(1)}KB, '
          'loop=${audioSequence.loop}',
          name: _logName,
        );
      } else {
        developer.log(
          '⚠️ Audio player not available or temp file creation failed',
          name: _logName,
        );
        _isPlaying = false;
      }

    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to play knot loading sound: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
    } finally {
      // Note: Don't set _isPlaying = false here - let stopAudio() handle it
      // The audio will continue playing until stopAudio() is called
    }
  }

  /// Stop playing audio
  Future<void> stopAudio() async {
    if (!_isPlaying) return;

    try {
      final player = _getOrCreateAudioPlayer();
      if (player != null) {
        await player.stop();
        await player.setReleaseMode(ReleaseMode.release);
      }
      _isPlaying = false;
      
      // Clean up temp file
      await _cleanupAudioFile();
      
      developer.log('Stopped audio playback', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error stopping audio: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      _isPlaying = false;
    }
  }

  /// Clean up temporary audio file
  Future<void> _cleanupAudioFile() async {
    if (_currentAudioFile != null) {
      try {
        if (await _currentAudioFile!.exists()) {
          await _currentAudioFile!.delete();
        }
      } catch (e) {
        developer.log(
          'Failed to delete temp audio file: $e',
          name: _logName,
        );
      }
      _currentAudioFile = null;
    }
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _cleanupAudioFile();
  }

  /// Generate audio data from musical pattern
  /// 
  /// Returns audio samples as a list of doubles (normalized to -1.0 to 1.0)
  Future<List<double>> generateAudioData(AudioSequence sequence) async {
    return _synthesizeAudio(sequence);
  }

  /// Synthesize audio from audio sequence
  /// 
  /// Generates audio samples by creating sine waves for each note
  /// and mixing them together with proper timing and volume.
  Future<List<double>> _synthesizeAudio(AudioSequence sequence) async {
    if (sequence.notes.isEmpty) {
      // Generate silence
      final silenceSamples = (_sampleRate * sequence.duration).round();
      return List<double>.filled(silenceSamples, 0.0);
    }

    // Calculate total samples needed
    final totalSamples = (_sampleRate * sequence.duration).round();
    final audioBuffer = List<double>.filled(totalSamples, 0.0);

    // Calculate note timing based on rhythm (BPM)
    final beatsPerSecond = sequence.rhythm / 60.0;
    final samplesPerBeat = (_sampleRate / beatsPerSecond).round();

    // Generate each note
    for (var noteIndex = 0; noteIndex < sequence.notes.length; noteIndex++) {
      final note = sequence.notes[noteIndex];
      
      // Calculate start position (stagger notes based on rhythm)
      final noteStartBeat = noteIndex % (sequence.notes.length);
      final startSample = (noteStartBeat * samplesPerBeat).clamp(0, totalSamples - 1);
      
      // Calculate note duration in samples
      final noteSamples = (note.duration * _sampleRate).round();
      final endSample = (startSample + noteSamples).clamp(0, totalSamples);

      // Generate sine wave for this note
      final twoPi = 2.0 * math.pi;
      final phaseIncrement = (note.frequency * twoPi) / _sampleRate;
      
      for (var i = startSample; i < endSample && i < totalSamples; i++) {
        final phase = (i - startSample) * phaseIncrement;
        
        // Generate sine wave with volume envelope (fade in/out to avoid clicks)
        final progress = (i - startSample) / noteSamples;
        final envelope = _calculateEnvelope(progress);
        final sample = math.sin(phase) * note.volume * envelope;
        
        // Mix with existing audio (additive synthesis)
        audioBuffer[i] += sample;
      }
    }

    // Add harmony (chord tones) as background
    if (sequence.harmony.isNotEmpty) {
      final harmonyVolume = 0.3; // Lower volume for harmony
      final harmonyStart = (totalSamples * 0.1).round(); // Start after 10%
      final harmonyEnd = (totalSamples * 0.9).round(); // End before 90%
      
      for (final harmonyFreq in sequence.harmony) {
        final twoPi = 2.0 * math.pi;
        final phaseIncrement = (harmonyFreq * twoPi) / _sampleRate;
        
        for (var i = harmonyStart; i < harmonyEnd && i < totalSamples; i++) {
          final phase = (i - harmonyStart) * phaseIncrement;
          final sample = math.sin(phase) * harmonyVolume;
          audioBuffer[i] += sample;
        }
      }
    }

    // Normalize to prevent clipping
    final maxAmplitude = audioBuffer.fold<double>(
      0.0,
      (max, sample) => math.max(max, sample.abs()),
    );
    
    if (maxAmplitude > 1.0) {
      final normalizationFactor = 1.0 / maxAmplitude;
      for (var i = 0; i < audioBuffer.length; i++) {
        audioBuffer[i] *= normalizationFactor;
      }
    }

    return audioBuffer;
  }

  /// Calculate volume envelope to prevent clicks
  /// 
  /// Applies fade in/out at the beginning and end of notes
  double _calculateEnvelope(double progress) {
    if (progress < 0.05) {
      // Fade in (first 5%)
      return progress / 0.05;
    } else if (progress > 0.95) {
      // Fade out (last 5%)
      return (1.0 - progress) / 0.05;
    } else {
      // Full volume
      return 1.0;
    }
  }

  /// Encode audio samples as WAV file
  /// 
  /// Converts normalized audio samples (-1.0 to 1.0) to 16-bit PCM WAV format
  Uint8List _encodeWav(List<double> samples) {
    final numSamples = samples.length;
    final dataSize = numSamples * _numChannels * (_bitsPerSample ~/ 8);
    final fileSize = 36 + dataSize; // Header size + data size

    final buffer = ByteData(44 + dataSize); // WAV header is 44 bytes

    // RIFF header
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint32(4, fileSize, Endian.little);
    buffer.setUint8(8, 0x57); // 'W'
    buffer.setUint8(9, 0x41); // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // fmt chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // fmt chunk size
    buffer.setUint16(20, 1, Endian.little); // audio format (1 = PCM)
    buffer.setUint16(22, _numChannels, Endian.little);
    buffer.setUint32(24, _sampleRate, Endian.little);
    buffer.setUint32(28, _sampleRate * _numChannels * (_bitsPerSample ~/ 8), Endian.little); // byte rate
    buffer.setUint16(32, _numChannels * (_bitsPerSample ~/ 8), Endian.little); // block align
    buffer.setUint16(34, _bitsPerSample, Endian.little);

    // data chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataSize, Endian.little);

    // Convert samples to 16-bit PCM
    var offset = 44;
    for (final sample in samples) {
      // Clamp to [-1.0, 1.0] and convert to 16-bit integer
      final clampedSample = sample.clamp(-1.0, 1.0);
      final intSample = (clampedSample * 32767.0).round().clamp(-32768, 32767);
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Save audio bytes to temporary file
  /// 
  /// Creates a temporary WAV file that can be played by audioplayers
  Future<File?> _saveToTempFile(Uint8List audioBytes) async {
    try {
      // Use system temp directory
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/knot_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      await tempFile.writeAsBytes(audioBytes);
      
      developer.log(
        'Saved audio to temp file: ${tempFile.path}',
        name: _logName,
      );
      
      return tempFile;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to save temp audio file: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return null;
    }
  }
}
