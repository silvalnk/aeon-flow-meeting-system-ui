import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import { makeHttpGetRoomUseCase, makeHttpDeleteRoomUseCase } from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";
import { RoomEntity } from "@domain/entities/index.ts";

interface Data {
  room?: RoomEntity;
  error?: string;
}

export const handler: Handlers<Data> = {
  async GET(req, ctx) {
    const { id } = ctx.params;
    const token = getTokenFromRequest(req);
    const result = await makeHttpGetRoomUseCase().execute({ id, token });

    if (isLeft(result)) {
      return ctx.render({ error: result.value.message });
    }

    return ctx.render({ room: result.value });
  },

  async POST(req, ctx) {
    const { id } = ctx.params;
    const form = await req.formData();
    if (form.get("_method") !== "DELETE") {
      return ctx.render({ error: "Método inválido" });
    }

    const token = getTokenFromRequest(req);
    const result = await makeHttpDeleteRoomUseCase().execute({ id, token });

    if (isLeft(result)) {
      const roomResult = await makeHttpGetRoomUseCase().execute({ id, token });
      return ctx.render({
        room: isLeft(roomResult) ? undefined : roomResult.value,
        error: result.value.message,
      });
    }

    return ctx.render(null, {
      headers: { Location: "/rooms" },
      status: 302,
    });
  },
};

export default function RoomDetailPage({ data }: PageProps<Data>) {
  const room = data?.room;
  return (
    <Layout title={room?.name ?? "Sala"}>
      <Alert type="error" message={data?.error ?? ""} />
      {room && (
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 max-w-2xl">
          <p class="text-slate-600 mb-2">{room.location}</p>
          <p class="mb-4"><span class="font-medium">Capacidade:</span> {room.capacity}</p>
          <div class="flex flex-wrap gap-2">
            <a href={`/rooms/${room.id}/reservations`} class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
              Ver Reservas
            </a>
            <a href={`/rooms/${room.id}/edit`} class="px-4 py-2 border rounded hover:bg-slate-50">Editar</a>
            <form method="POST" class="inline">
              <input type="hidden" name="_method" value="DELETE" />
              <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">
                Excluir
              </button>
            </form>
          </div>
        </div>
      )}
    </Layout>
  );
}
