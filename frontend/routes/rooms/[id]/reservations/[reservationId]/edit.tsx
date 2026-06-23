import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "../../../../../components/Layout.tsx";
import Alert from "../../../../../components/Alert.tsx";
import { toDatetimeLocal } from "../../../../../shared_domain/formatters.ts";
import {
  makeHttpGetReservationUseCase,
  makeHttpGetRoomUseCase,
  makeHttpUpdateReservationUseCase,
} from "../../../../../main/factories/usecases/index.ts";
import { isLeft } from "../../../../../shared_domain/either.ts";
import { getTokenFromRequest } from "../../../../_middleware.ts";
import { ReservationEntity, RoomEntity } from "../../../../../domain/entities/index.ts";

interface Data {
  room?: RoomEntity;
  reservation?: ReservationEntity;
  error?: string;
}

export const handler: Handlers<Data> = {
  async GET(req, ctx) {
    const { id: roomId, reservationId } = ctx.params;
    const token = getTokenFromRequest(req);

    const [roomResult, reservationResult] = await Promise.all([
      makeHttpGetRoomUseCase().execute({ id: roomId, token }),
      makeHttpGetReservationUseCase().execute({ roomId, id: reservationId, token }),
    ]);

    if (isLeft(roomResult) || isLeft(reservationResult)) {
      return ctx.render({
        error: isLeft(roomResult) ? roomResult.value.message : reservationResult.value.message,
      });
    }

    return ctx.render({ room: roomResult.value, reservation: reservationResult.value });
  },

  async POST(req, ctx) {
    const { id: roomId, reservationId } = ctx.params;
    const form = await req.formData();
    const token = getTokenFromRequest(req);

    const result = await makeHttpUpdateReservationUseCase().execute({
      roomId,
      id: reservationId,
      start_time: new Date(String(form.get("start_time"))).toISOString(),
      end_time: new Date(String(form.get("end_time"))).toISOString(),
      description: String(form.get("description") || ""),
      responsible: String(form.get("responsible")),
      status: String(form.get("status")),
      token,
    });

    if (isLeft(result)) {
      const reservationResult = await makeHttpGetReservationUseCase().execute({
        roomId,
        id: reservationId,
        token,
      });
      const roomResult = await makeHttpGetRoomUseCase().execute({ id: roomId, token });
      return ctx.render({
        room: isLeft(roomResult) ? undefined : roomResult.value,
        reservation: isLeft(reservationResult) ? undefined : reservationResult.value,
        error: result.value.message,
      });
    }

    return ctx.render(null, {
      headers: { Location: `/rooms/${roomId}/reservations/${reservationId}` },
      status: 302,
    });
  },
};

export default function EditReservationPage({ data }: PageProps<Data>) {
  const { room, reservation } = data ?? {};
  return (
    <Layout title="Editar Reserva">
      <Alert type="error" message={data?.error ?? ""} />
      {room && reservation && (
        <form method="POST" class="max-w-lg bg-white p-6 rounded-lg shadow-sm border border-slate-200">
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="responsible">Responsável</label>
            <input
              id="responsible"
              name="responsible"
              required
              maxLength={100}
              value={reservation.responsible}
              class="w-full border rounded px-3 py-2"
            />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="start_time">Início</label>
            <input
              id="start_time"
              name="start_time"
              type="datetime-local"
              required
              value={toDatetimeLocal(reservation.start_time)}
              class="w-full border rounded px-3 py-2"
            />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="end_time">Fim</label>
            <input
              id="end_time"
              name="end_time"
              type="datetime-local"
              required
              value={toDatetimeLocal(reservation.end_time)}
              class="w-full border rounded px-3 py-2"
            />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1" for="description">Descrição</label>
            <textarea id="description" name="description" rows={3} class="w-full border rounded px-3 py-2">
              {reservation.description ?? ""}
            </textarea>
          </div>
          <div class="mb-6">
            <label class="block text-sm font-medium mb-1" for="status">Status</label>
            <select id="status" name="status" class="w-full border rounded px-3 py-2">
              <option value="pending" selected={reservation.status === "pending"}>Pendente</option>
              <option value="confirmed" selected={reservation.status === "confirmed"}>Confirmada</option>
              <option value="cancelled" selected={reservation.status === "cancelled"}>Cancelada</option>
            </select>
          </div>
          <div class="flex gap-2">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Salvar</button>
            <a
              href={`/rooms/${room.id}/reservations/${reservation.id}`}
              class="px-4 py-2 border rounded hover:bg-slate-50"
            >
              Cancelar
            </a>
          </div>
        </form>
      )}
    </Layout>
  );
}
