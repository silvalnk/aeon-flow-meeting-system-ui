import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import { makeHttpCreateRoomUseCase } from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";

interface Data {
  error?: string;
}

export const handler: Handlers<Data> = {
  async POST(req, ctx) {
    const form = await req.formData();
    const token = getTokenFromRequest(req);
    const result = await makeHttpCreateRoomUseCase().execute({
      name: String(form.get("name")),
      capacity: Number(form.get("capacity")),
      location: String(form.get("location")),
      token,
    });

    if (isLeft(result)) {
      return ctx.render({ error: result.value.message });
    }

    return ctx.render(null, {
      headers: { Location: `/rooms/${result.value.id}` },
      status: 302,
    });
  },
};

export default function NewRoomPage({ data }: PageProps<Data>) {
  return (
    <Layout title="Nova Sala">
      <Alert type="error" message={data?.error ?? ""} />
      <form method="POST" class="max-w-lg bg-white p-6 rounded-lg shadow-sm border border-slate-200">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="name">Nome</label>
          <input id="name" name="name" required maxLength={100} class="w-full border rounded px-3 py-2" />
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="capacity">Capacidade</label>
          <input id="capacity" name="capacity" type="number" min="1" required class="w-full border rounded px-3 py-2" />
        </div>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1" for="location">Localização</label>
          <input id="location" name="location" required class="w-full border rounded px-3 py-2" />
        </div>
        <div class="flex gap-2">
          <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Criar</button>
          <a href="/rooms" class="px-4 py-2 border rounded hover:bg-slate-50">Cancelar</a>
        </div>
      </form>
    </Layout>
  );
}
