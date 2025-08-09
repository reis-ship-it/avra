# ML Models

This directory contains machine learning models used by the application.

## Required Models

### default.onnx
- Purpose: Main inference model for AI2AI system
- Size: ~418MB
- Not included in repository due to size limitations
- How to obtain:
  1. Run the model export script: `python scripts/ml/export_sample_onnx.py`
  2. Or download from our model registry (contact team for access)
  3. Place the file in this directory as `default.onnx`

## Model Versions
The application expects specific model versions. Ensure you're using the correct version:
- default.onnx: v1.0.0 (MD5: contact team for hash)

## Notes
- Models are not tracked in git due to size
- Keep local copies backed up
- See documentation for model update procedures
