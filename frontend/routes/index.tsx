import { Handlers, PageProps } from "$fresh/server.ts";

export const handler: Handlers = {
  GET(_req, ctx) {
    return ctx.render(null, {
      headers: { Location: "/rooms" },
      status: 302,
    });
  },
};

export default function Home(_props: PageProps) {
  return null;
}
