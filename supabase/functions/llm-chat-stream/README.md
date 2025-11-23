# LLM Chat Stream Edge Function

## Overview

This Supabase Edge Function provides **Server-Sent Events (SSE) streaming** for Google Gemini LLM responses. It enables real-time word-by-word streaming of AI responses to the client.

## Features

- **True SSE Streaming:** Real-time response streaming from Gemini API
- **Full Context Support:** Personality, vibe, AI2AI insights, connection metrics
- **Error Handling:** Graceful handling of stream interruptions
- **CORS Enabled:** Works with web and mobile clients

## API

### Endpoint

```
POST /llm-chat-stream
```

### Request Body

```json
{
  "messages": [
    {"role": "user", "content": "Find coffee shops near me"}
  ],
  "context": {
    "userId": "user-123",
    "location": {"lat": 40.7128, "lng": -74.0060},
    "personality": { ... },
    "vibe": { ... },
    "ai2aiInsights": [ ... ],
    "connectionMetrics": { ... }
  },
  "temperature": 0.7,
  "maxTokens": 500
}
```

### Response Format (SSE)

The response is a Server-Sent Events stream:

```
data: {"text": "I"}

data: {"text": " found"}

data: {"text": " some"}

data: {"text": " great"}

data: {"text": " coffee"}

data: {"text": " shops"}

data: {"done": true}
```

## Client Usage

### Dart/Flutter

```dart
final response = await http.post(
  Uri.parse('$supabaseUrl/functions/v1/llm-chat-stream'),
  headers: {
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(request),
);

final stream = response.body
  .transform(utf8.decoder)
  .transform(LineSplitter())
  .where((line) => line.startsWith('data: '))
  .map((line) => line.substring(6))
  .map((data) => jsonDecode(data));

await for (final event in stream) {
  if (event['text'] != null) {
    print(event['text']);
  }
  if (event['done'] == true) {
    break;
  }
}
```

## Deployment

```bash
supabase functions deploy llm-chat-stream
```

## Environment Variables

- `GEMINI_API_KEY`: Google Gemini API key (required)

## Error Handling

The stream may send error events:

```
data: {"error": "Error message"}
```

Clients should handle these gracefully and display appropriate error messages.

## Performance

- **Latency:** First token in ~200-500ms
- **Throughput:** ~10-20 tokens/second (depends on Gemini API)
- **Timeout:** No timeout (stream stays open until complete)

## Comparison with Non-Streaming

| Feature | Non-Streaming | SSE Streaming |
|---------|---------------|---------------|
| First response | 3-5 seconds | 0.2-0.5 seconds |
| User perception | Slow | Fast & responsive |
| Long responses | Blocking | Progressive |
| Bandwidth | All at once | Incremental |

## Notes

- This replaces the simulated streaming in `LLMService.chatStream()`
- The Gemini API SSE endpoint is: `streamGenerateContent?alt=sse`
- Connection recovery should be handled client-side

