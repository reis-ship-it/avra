// Federated Sync Edge Function for Phase 11: User-AI Interaction Update
// Section 7: Federated Learning Hooks
// Syncs federated updates to edge functions - aggregates deltas from multiple agents

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { agentId, deltas } = body

    if (!agentId) {
      return new Response(
        JSON.stringify({ error: 'agentId is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!deltas || !Array.isArray(deltas) || deltas.length === 0) {
      return new Response(
        JSON.stringify({ error: 'deltas array is required and must not be empty' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Aggregate deltas by category
    const aggregatedDeltas = aggregateDeltasByCategory(deltas)

    // Store aggregated deltas for cloud model updates
    // TODO: Create federated_deltas table for storing aggregated deltas
    // For now, we'll log the aggregation
    console.log(`Aggregated ${deltas.length} deltas from agent ${agentId.substring(0, 10)}...`)
    console.log(`Categories: ${Object.keys(aggregatedDeltas).join(', ')}`)

    // Calculate average deltas per category
    const averageDeltas = calculateAverageDeltas(aggregatedDeltas)

    // TODO: Update cloud models with aggregated deltas
    // This would update the global model weights based on federated learning
    // For now, we just return the aggregated results

    return new Response(
      JSON.stringify({
        success: true,
        agentId: agentId.substring(0, 10) + '...', // Truncate for privacy
        deltaCount: deltas.length,
        categories: Object.keys(aggregatedDeltas),
        averageDeltas: averageDeltas,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (e) {
    console.error('Federated sync error:', e)
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

/// Aggregate deltas by category
function aggregateDeltasByCategory(deltas: any[]) {
  const aggregated: Record<string, any[]> = {}

  for (const delta of deltas) {
    const category = delta.category || 'general'
    if (!aggregated[category]) {
      aggregated[category] = []
    }
    aggregated[category].push(delta)
  }

  return aggregated
}

/// Calculate average deltas per category
function calculateAverageDeltas(aggregatedDeltas: Record<string, any[]>) {
  const averages: Record<string, number[]> = {}

  for (const [category, deltas] of Object.entries(aggregatedDeltas)) {
    if (deltas.length === 0) continue

    // Find maximum delta length
    let maxLength = 0
    for (const delta of deltas) {
      if (delta.delta && delta.delta.length > maxLength) {
        maxLength = delta.delta.length
      }
    }

    // Calculate average for each dimension
    const avgDelta = new Array(maxLength).fill(0)
    for (const delta of deltas) {
      if (delta.delta) {
        for (let i = 0; i < delta.delta.length && i < maxLength; i++) {
          avgDelta[i] += delta.delta[i]
        }
      }
    }

    // Divide by count to get average
    for (let i = 0; i < avgDelta.length; i++) {
      avgDelta[i] /= deltas.length
    }

    averages[category] = avgDelta
  }

  return averages
}
