import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import { makeHttpGetRoomUseCase, makeHttpUpdateRoomUseCase } from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";
import { requireAuth, unauthorizedRedirect, redirectTo } from "@infrastructure/auth/session.ts";
import { RoomEntity } from "@domain/entities/index.ts";

interface Data {
  room?: RoomEntity;
  error?: string;
}

export const handler: Handlers<Data> = {
  async GET(req, ctx) {
    const denied = requireAuth(req);
    if (denied) return denied;

    const { id } = ctx.params;
    const token = getTokenFromRequest(req);
    const result = await makeHttpGetRoomUseCase().execute({ id, token });

    if (isLeft(result)) {
      return ctx.render({ error: result.value.message });
    }

    return ctx.render({ room: result.value });
  },

  async POST(req, ctx) {
    const denied = requireAuth(req);
    if (denied) return denied;

    const { id } = ctx.params;
    const form = await req.formData();
    const token = getTokenFromRequest(req);
    const result = await makeHttpUpdateRoomUseCase().execute({
      id,
      name: String(form.get("name")),
      capacity: Number(form.get("capacity")),
      location: String(form.get("location")),
      token,
    });

    if (isLeft(result)) {
      const redirect = unauthorizedRedirect(req, result.value.statusCode);
      if (redirect) return redirect;
      const roomResult = await makeHttpGetRoomUseCase().execute({ id, token });
      return ctx.render({
        room: isLeft(roomResult) ? undefined : roomResult.value,
        error: result.value.message,
      });
    }

    return redirectTo(`/rooms/${id}`);
  },
};

export default function EditRoomPage({ data }: PageProps<Data>) {
  const room = data?.room;
  return (
    <Layout title="Editar Sala" authenticated>
      <Alert type="error" message={data?.error ?? ""} />
      {room && (
        <form method="POST" class="max-w-lg bg-white p-6 rounded-lg shadow-sm border border-slate-200">
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="name">Nome</label>
            <input id="name" name="name" required maxLength={100} value={room.name} class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="capacity">Capacidade</label>
            <input id="capacity" name="capacity" type="number" min="1" required value={room.capacity} class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-6">
            <label class="block text-sm font-medium mb-1" for="location">Localização</label>
            <input id="location" name="location" required value={room.location} class="w-full border rounded px-3 py-2" />
          </div>
          <div class="flex gap-2">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Salvar</button>
            <a href={`/rooms/${room.id}`} class="px-4 py-2 border rounded hover:bg-slate-50">Cancelar</a>
          </div>
        </form>
      )}
    </Layout>
  );
}
