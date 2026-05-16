import { serve } from "https://deno.land/std/http/server.ts";

serve(async () => {
  return new Response(
    JSON.stringify({
      ok: true,
      version: "NEW-RUN"
    }),
    {
      headers: { "Content-Type": "application/json" }
    }
  );
});