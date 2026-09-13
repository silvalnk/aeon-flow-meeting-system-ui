import { Handlers } from "$fresh/server.ts";
import { buildClearAuthCookie } from "@infrastructure/auth/token-storage.ts";

export const handler: Handlers = {
  GET() {
    return new Response(null, {
      status: 302,
      headers: {
        Location: "/rooms",
        "Set-Cookie": buildClearAuthCookie(),
      },
    });
  },
};

export default function LogoutPage() {
  return null;
}
