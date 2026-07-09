import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const body = await req.json()

    const {
      competitionId,
      boulderId,
      registrationId,
    } = body

    if (!competitionId || !boulderId || !registrationId) {
      throw new Error(
        'competitionId, boulderId e registrationId sono obbligatori',
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // ============================================
    // CHECK REGISTRATION ESISTE ED È DELLA GARA CORRETTA
    // ============================================

    const {
      data: registration,
      error: registrationError,
    } = await supabase
      .from('registrations')
      .select('id, competition_id')
      .eq('id', registrationId)
      .maybeSingle()

    if (registrationError) throw registrationError

    if (!registration) {
      return jsonResponse({
        success: false,
        message: 'Iscrizione non trovata',
      })
    }

    if (registration.competition_id !== competitionId) {
      return jsonResponse({
        success: false,
        message: 'Boulder non valido per questa gara',
      })
    }

    // ============================================
    // CHECK BOULDER ESISTE, È DELLA GARA CORRETTA
    // E NON È UN BOULDER DI FINALE
    // ============================================

    const {
      data: boulder,
      error: boulderError,
    } = await supabase
      .from('boulders')
      .select('id, competition_id, is_finale')
      .eq('id', boulderId)
      .maybeSingle()

    if (boulderError) throw boulderError

    if (!boulder) {
      return jsonResponse({
        success: false,
        message: 'Boulder non trovato',
      })
    }

    if (boulder.competition_id !== competitionId) {
      return jsonResponse({
        success: false,
        message: 'Boulder non valido per questa gara',
      })
    }

    if (boulder.is_finale === true) {
      return jsonResponse({
        success: false,
        message: 'Boulder non valido in qualificazione',
      })
    }

    // ============================================
    // CHECK ASCENSIONE GIÀ REGISTRATA
    // ============================================

    const {
      data: existingAscent,
      error: existingError,
    } = await supabase
      .from('ascents')
      .select('registration_id, boulder_id, top')
      .eq('registration_id', registrationId)
      .eq('boulder_id', boulderId)
      .maybeSingle()

    if (existingError) throw existingError

    if (existingAscent && existingAscent.top === true) {
      return jsonResponse({
        success: false,
        message: 'Boulder già effettuato',
      })
    }

    // ============================================
    // INSERT O UPDATE — top=true, tentativi_top=1
    // ============================================
    // Se esiste già una riga (es. zone registrata da altra
    // fonte) la aggiorniamo; altrimenti la creiamo.

    const nowIso = new Date().toISOString()

    if (existingAscent) {
      const { error: updateError } = await supabase
        .from('ascents')
        .update({
          top: true,
          zone: true,
          tentativi_top: 1,
          tentativi_zone: 1,
          updated_at: nowIso,
        })
        .eq('registration_id', registrationId)
        .eq('boulder_id', boulderId)

      if (updateError) throw updateError
    } else {
      const { error: insertError } = await supabase
        .from('ascents')
        .insert({
          registration_id: registrationId,
          boulder_id: boulderId,
          top: true,
          zone: true,
          tentativi_top: 1,
          tentativi_zone: 1,
          created_at: nowIso,
          updated_at: nowIso,
        })

      if (insertError) throw insertError
    }

    return jsonResponse({
      success: true,
      message: 'Boulder registrato',
    })

  } catch (err) {
    console.error('REGISTER ASCENT ERROR:', err)

    return new Response(
      JSON.stringify({
        success: false,
        message: err.message,
      }),
      { status: 500 },
    )
  }
})

function jsonResponse(payload: Record<string, unknown>) {
  return new Response(
    JSON.stringify(payload),
    {
      headers: { 'Content-Type': 'application/json' },
    },
  )
}