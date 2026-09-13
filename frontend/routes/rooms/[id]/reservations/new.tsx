import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import { makeHttpCreateReservationUseCase, makeHttpGetRoomUseCase } from "@factories/usecases/index.ts";
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

    const { id: roomId } = ctx.params;
    const token = getTokenFromRequest(req);
    const result = await makeHttpGetRoomUseCase().execute({ id: roomId, token });
    if (isLeft(result)) return ctx.render({ error: result.value.message });
    return ctx.render({ room: result.value });
  },

  async POST(req, ctx) {
    const denied = requireAuth(req);
    if (denied) return denied;

    const { id: roomId } = ctx.params;
    const form = await req.formData();
    const token = getTokenFromRequest(req);
    const result = await makeHttpCreateReservationUseCase().execute({
      roomId,
      start_time: new Date(String(form.get("start_time"))).toISOString(),
      end_time: new Date(String(form.get("end_time"))).toISOString(),
      description: String(form.get("description") || ""),
      responsible: String(form.get("responsible")),
      status: String(form.get("status") || "pending"),
      token,
    });

    if (isLeft(result)) {
      const redirect = unauthorizedRedirect(req, result.value.statusCode);
      if (redirect) return redirect;
      const roomResult = await makeHttpGetRoomUseCase().execute({ id: roomId, token });
      return ctx.render({
        room: isLeft(roomResult) ? undefined : roomResult.value,
        error: result.value.message,
      });
    }

    return redirectTo(`/rooms/${roomId}/reservations/${result.value.id}`);
  },
};

export default function NewReservationPage({ data }: PageProps<Data>) {
  const room = data?.room;
  return (
    <Layout title="Nova Reserva" authenticated>
      <Alert type="error" message={data?.error ?? ""} />
      {room && (
        <form method="POST" class="max-w-lg bg-white p-6 rounded-lg shadow-sm border border-slate-200">
          <p class="text-sm text-slate-600 mb-4">Sala: <strong>{room.name}</strong></p>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="responsible">Responsável</label>
            <input id="responsible" name="responsible" required maxLength={100} class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="start_time">Início</label>
            <input id="start_time" name="start_time" type="datetime-local" required class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="end_time">Fim</label>
            <input id="end_time" name="end_time" type="datetime-local" required class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="description">Descrição</label>
            <textarea id="description" name="description" rows={3} class="w-full border rounded px-3 py-2" />
          </div>
          <div class="mb-6">
            <label class="block text-sm font-medium mb-1" for="status">Status</label>
            <select id="status" name="status" class="w-full border rounded px-3 py-2">
              <option value="pending">Pendente</option>
              <option value="confirmed">Confirmada</option>
            </select>
          </div>
          <div class="flex gap-2">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Criar</button>
            <a href={`/rooms/${room.id}/reservations`} class="px-4 py-2 border rounded hover:bg-slate-50">Cancelar</a>
          </div>
        </form>
      )}
    </Layout>
  );
}
