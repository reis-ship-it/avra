# LLM Integration Setup Guide

This guide will help you set up Google Gemini LLM integration for SPOTS.

## 🚀 Quick Start

### Step 1: Get Google Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key (starts with `AIza...`)

### Step 2: Deploy the Edge Function

```bash
# Make sure you're in the project root
cd /path/to/SPOTS

# Deploy the LLM chat function
supabase functions deploy llm-chat --no-verify-jwt
```

### Step 3: Set the API Key Secret

```bash
# Set your Gemini API key as a Supabase secret
supabase secrets set GEMINI_API_KEY=your_api_key_here
```

**Important:** Replace `your_api_key_here` with your actual API key from Step 1.

### Step 4: Verify Deployment

```bash
# Test the function
curl -X POST https://your-project.supabase.co/functions/v1/llm-chat \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello! Can you help me find coffee shops?"}
    ]
  }'
```

## 📋 Configuration

### Environment Variables

The function uses the following environment variable:
- `GEMINI_API_KEY` - Your Google Gemini API key (required)

### Model Configuration

The function uses `gemini-pro` by default (free tier). To change the model, edit `supabase/functions/llm-chat/index.ts` and update the `model` variable.

Available models:
- `gemini-pro` - Free tier, good for most use cases
- `gemini-pro-vision` - For image understanding (requires API key upgrade)

## 🔧 Troubleshooting

### Function Not Found

If you get a 404 error:
1. Make sure you deployed the function: `supabase functions deploy llm-chat`
2. Check your Supabase project URL is correct
3. Verify you're using the correct function name (`llm-chat`)

### API Key Error

If you get "GEMINI_API_KEY not configured":
1. Make sure you set the secret: `supabase secrets set GEMINI_API_KEY=...`
2. Verify the secret name matches exactly: `GEMINI_API_KEY`
3. Redeploy the function after setting the secret

### Rate Limit Errors

Google Gemini free tier has rate limits:
- 60 requests per minute
- If you hit limits, the function will return an error

Solutions:
- Add retry logic in your Dart code
- Upgrade to paid tier for higher limits
- Implement request queuing

## 💰 Cost Information

**Google Gemini Free Tier:**
- 60 requests per minute
- 1,500 requests per day
- No credit card required

**Paid Tier (if needed):**
- $0.00025 per 1K characters input
- $0.0005 per 1K characters output
- Very affordable for most apps

## 🧪 Testing

### Test from Dart Code

```dart
import 'package:spots/core/services/llm_service.dart';
import 'package:get_it/get_it.dart';

final llmService = GetIt.instance<LLMService>();

final response = await llmService.generateRecommendation(
  userQuery: 'Find coffee shops near me',
  userContext: LLMContext(
    location: Position(latitude: 40.7128, longitude: -74.0060),
  ),
);

print(response);
```

### Test from Terminal

```bash
# Using curl
curl -X POST https://your-project.supabase.co/functions/v1/llm-chat \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello!"}
    ],
    "context": {
      "location": {"lat": 40.7128, "lng": -74.0060}
    }
  }'
```

## 📚 Next Steps

1. ✅ Deploy the function
2. ✅ Set your API key
3. ✅ Test the integration
4. Update your UI to use the LLM service
5. Add error handling and retry logic
6. Monitor usage and costs

## 🔒 Security Notes

- API keys are stored securely in Supabase secrets
- Never commit API keys to git
- Use environment variables for local development
- Rotate keys periodically

## 📖 Additional Resources

- [Google Gemini API Docs](https://ai.google.dev/docs)
- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [SPOTS LLM Integration Guide](../VIBE_CODING/DEPLOYMENT/llm_integration_assessment.md)

