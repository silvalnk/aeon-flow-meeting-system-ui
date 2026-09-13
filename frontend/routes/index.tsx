import { Handlers, PageProps } from "$fresh/server.ts";
import { redirectTo } from "@infrastructure/auth/session.ts";

export const handler: Handlers = {
  GET() {
    return redirectTo("/rooms");
  },
};

export default function Home(_props: PageProps) {
  return null;
}
