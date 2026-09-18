import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import { makeHttpCreateRoomUseCase } from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";
import { requireAuth, unauthorizedRedirect, redirectTo } from "@infrastructure/auth/session.ts";

interface Data {
  error?: string;
}

export const handler: Handlers<Data> = {
  GET(req, ctx) {
    const denied = requireAuth(req);
    if (denied) return denied;
    return ctx.render({});
  },

  async POST(req, ctx) {
    const denied = requireAuth(req);
    if (denied) return denied;

    const form = await req.formData();
    const token = getTokenFromRequest(req);
    const result = await makeHttpCreateRoomUseCase().execute({
      name: String(form.get("name")),
      capacity: Number(form.get("capacity")),
      location: String(form.get("location")),
      token,
    });

    if (isLeft(result)) {
      const redirect = unauthorizedRedirect(req, result.value.statusCode);
      if (redirect) return redirect;
      return ctx.render({ error: result.value.message });
    }

    return redirectTo(`/rooms/${result.value.id}`);
  },
};

export default function NewRoomPage({ data }: PageProps<Data>) {
  return (
    <Layout title="New room" authenticated>
      <Alert type="error" message={data?.error ?? ""} />
      <form method="POST" class="max-w-lg bg-white p-6 rounded-lg shadow-sm border border-slate-200">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="name">Name</label>
          <input id="name" name="name" required maxLength={100} class="w-full border rounded px-3 py-2" />
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="capacity">Capacity</label>
          <input id="capacity" name="capacity" type="number" min="1" required class="w-full border rounded px-3 py-2" />
        </div>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1" for="location">Location</label>
          <input id="location" name="location" required class="w-full border rounded px-3 py-2" />
        </div>
        <div class="flex gap-2">
          <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Create</button>
          <a href="/rooms" class="px-4 py-2 border rounded hover:bg-slate-50">Cancel</a>
        </div>
      </form>
    </Layout>
  );
}
