import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import ReservationRow from "@components/ReservationRow.tsx";
import {
  makeHttpGetRoomUseCase,
  makeHttpListReservationsUseCase,
} from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";
import { isAuthenticated } from "@infrastructure/auth/session.ts";
import { ReservationEntity, RoomEntity } from "@domain/entities/index.ts";

interface Data {
  room?: RoomEntity;
  reservations: ReservationEntity[];
  filters: { status?: string; search?: string };
  error?: string;
  authenticated: boolean;
}

export const handler: Handlers<Data> = {
  async GET(req, ctx) {
    const { id: roomId } = ctx.params;
    const url = new URL(req.url);
    const status = url.searchParams.get("status") ?? undefined;
    const search = url.searchParams.get("search") ?? undefined;
    const token = getTokenFromRequest(req);
    const authenticated = isAuthenticated(req);

    const roomResult = await makeHttpGetRoomUseCase().execute({ id: roomId, token });
    const reservationsResult = await makeHttpListReservationsUseCase().execute({
      roomId,
      status,
      search,
      token,
    });

    if (isLeft(roomResult)) {
      return ctx.render({
        reservations: [],
        filters: { status, search },
        error: roomResult.value.message,
        authenticated,
      });
    }

    if (isLeft(reservationsResult)) {
      return ctx.render({
        room: roomResult.value,
        reservations: [],
        filters: { status, search },
        error: reservationsResult.value.message,
        authenticated,
      });
    }

    return ctx.render({
      room: roomResult.value,
      reservations: reservationsResult.value,
      filters: { status, search },
      authenticated,
    });
  },
};

export default function RoomReservationsPage({ data }: PageProps<Data>) {
  const room = data?.room;
  const authenticated = data?.authenticated ?? false;
  return (
    <Layout title={room ? `Reservas — ${room.name}` : "Reservas"} authenticated={authenticated}>
      <Alert type="error" message={data?.error ?? ""} />
      {room && (
        <>
          <div class="mb-4 flex flex-wrap gap-2">
            {authenticated && (
              <a href={`/rooms/${room.id}/reservations/new`} class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                Nova Reserva
              </a>
            )}
            <a href={`/rooms/${room.id}`} class="px-4 py-2 border rounded hover:bg-slate-50">Voltar à Sala</a>
          </div>
          <form method="GET" class="mb-6 grid grid-cols-1 sm:grid-cols-3 gap-2">
            <input
              type="search"
              name="search"
              value={data?.filters.search ?? ""}
              placeholder="Buscar responsável..."
              class="border rounded px-3 py-2"
            />
            <select name="status" class="border rounded px-3 py-2">
              <option value="">Todos os status</option>
              <option value="confirmed" selected={data?.filters.status === "confirmed"}>Confirmada</option>
              <option value="pending" selected={data?.filters.status === "pending"}>Pendente</option>
              <option value="cancelled" selected={data?.filters.status === "cancelled"}>Cancelada</option>
            </select>
            <button type="submit" class="px-4 py-2 bg-slate-800 text-white rounded hover:bg-slate-900">Filtrar</button>
          </form>
          <div class="overflow-x-auto bg-white rounded-lg shadow-sm border border-slate-200">
            <table class="w-full text-left">
              <thead class="bg-slate-50 text-sm">
                <tr>
                  <th class="px-4 py-3">Responsável</th>
                  <th class="px-4 py-3">Início</th>
                  <th class="px-4 py-3">Fim</th>
                  <th class="px-4 py-3">Status</th>
                  <th class="px-4 py-3">Descrição</th>
                  <th class="px-4 py-3">Ações</th>
                </tr>
              </thead>
              <tbody>
                {data?.reservations.length === 0
                  ? (
                    <tr>
                      <td colSpan={6} class="px-4 py-6 text-center text-slate-500">Nenhuma reserva encontrada.</td>
                    </tr>
                  )
                  : data?.reservations.map((r) => (
                    <ReservationRow key={r.id} reservation={r} roomId={room.id} canEdit={authenticated} />
                  ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </Layout>
  );
}
