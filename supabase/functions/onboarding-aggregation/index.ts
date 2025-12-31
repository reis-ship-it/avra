// Supabase Edge Function: Onboarding Aggregation
// Phase 11 Section 4: Edge Mesh Functions
// Aggregates onboarding data and maps to personality dimensions

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface OnboardingData {
  age?: number
  birthday?: string
  homebase?: string
  favoritePlaces?: string[]
  preferences?: Record<string, string[]>
  baselineLists?: string[]
  respectedFriends?: string[]
  socialMediaConnected?: Record<string, boolean>
  completedAt?: string
}

interface RequestBody {
  agentId: string
  onboardingData: OnboardingData
}

function supabaseAdmin() {
  const url = Deno.env.get('SUPABASE_URL')!
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  return createClient(url, serviceKey, {
    auth: { persistSession: false },
  })
}

function mapOnboardingToDimensions(aggregated: any): Record<string, number> {
  // Rule-based mapping: onboarding → dimensions
  // Similar to PersonalityLearning logic
  const dimensions: Record<string, number> = {}
  
  // Exploration eagerness: based on favorite places and baseline lists
  if (aggregated.favoritePlaces > 5 || aggregated.baselineLists > 3) {
    dimensions['exploration_eagerness'] = 0.7
  } else if (aggregated.favoritePlaces > 0 || aggregated.baselineLists > 0) {
    dimensions['exploration_eagerness'] = 0.6
  } else {
    dimensions['exploration_eagerness'] = 0.5
  }
  
  // Community orientation: based on respected friends and social media connections
  const socialConnections = aggregated.respectedFriends + 
    (aggregated.socialMediaConnected ? Object.keys(aggregated.socialMediaConnected).length : 0)
  if (socialConnections > 10) {
    dimensions['community_orientation'] = 0.8
  } else if (socialConnections > 5) {
    dimensions['community_orientation'] = 0.7
  } else if (socialConnections > 0) {
    dimensions['community_orientation'] = 0.6
  } else {
    dimensions['community_orientation'] = 0.5
  }
  
  // Location adventurousness: based on homebase and favorite places
  if (aggregated.homebase && aggregated.favoritePlaces > 3) {
    dimensions['location_adventurousness'] = 0.7
  } else if (aggregated.homebase || aggregated.favoritePlaces > 0) {
    dimensions['location_adventurousness'] = 0.6
  } else {
    dimensions['location_adventurousness'] = 0.5
  }
  
  // Authenticity preference: based on preferences
  if (aggregated.preferences && Object.keys(aggregated.preferences).length > 0) {
    dimensions['authenticity_preference'] = 0.7
  } else {
    dimensions['authenticity_preference'] = 0.5
  }
  
  // Trust network reliance: based on social connections
  if (socialConnections > 5) {
    dimensions['trust_network_reliance'] = 0.7
  } else {
    dimensions['trust_network_reliance'] = 0.5
  }
  
  // Temporal flexibility: default
  dimensions['temporal_flexibility'] = 0.5
  
  return dimensions
}

serve(async (req) => {
  try {
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }

    // Handle OPTIONS request
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders })
    }

    const body: RequestBody = await req.json()
    const { agentId, onboardingData } = body

    if (!agentId || !onboardingData) {
      return new Response(
        JSON.stringify({ error: 'agentId and onboardingData are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Aggregate onboarding data
    const aggregated = {
      age: onboardingData.age,
      homebase: onboardingData.homebase,
      favoritePlaces: onboardingData.favoritePlaces?.length ?? 0,
      preferences: onboardingData.preferences || {},
      baselineLists: onboardingData.baselineLists?.length ?? 0,
      respectedFriends: onboardingData.respectedFriends?.length ?? 0,
      socialMediaConnected: onboardingData.socialMediaConnected || {},
    }

    // Map to dimensions (rule-based)
    const dimensions = mapOnboardingToDimensions(aggregated)

    // Store aggregated data
    const supabase = supabaseAdmin()
    
    const { error } = await supabase
      .from('onboarding_aggregations')
      .upsert({
        agent_id: agentId,
        aggregated_data: aggregated,
        dimensions: dimensions,
        updated_at: new Date().toISOString(),
      }, {
        onConflict: 'agent_id',
      })

    if (error) {
      console.error('Error storing aggregation:', error)
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true, dimensions }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (e) {
    console.error('Onboarding aggregation error:', e)
    return new Response(
      JSON.stringify({ error: String(e) }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
