import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "../../../../components/Layout.tsx";
import Alert from "../../../../components/Alert.tsx";
import StatusBadge from "../../../../components/StatusBadge.tsx";
import { formatDateTime } from "../../../../shared_domain/formatters.ts";
import {
  makeHttpCancelReservationUseCase,
  makeHttpGetReservationUseCase,
  makeHttpGetRoomUseCase,
} from "../../../../main/factories/usecases/index.ts";
import { isLeft } from "../../../../shared_domain/either.ts";
import { getTokenFromRequest } from "../../../_middleware.ts";
import { ReservationEntity, RoomEntity } from "../../../../domain/entities/index.ts";

interface Data {
  room?: RoomEntity;
  reservation?: ReservationEntity;
  success?: string;
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

    if (form.get("_method") === "DELETE") {
      const result = await makeHttpCancelReservationUseCase().execute({
        roomId,
        id: reservationId,
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
        headers: { Location: `/rooms/${roomId}/reservations` },
        status: 302,
      });
    }

    return ctx.render({ error: "Método inválido" });
  },
};

export default function ReservationDetailPage({ data }: PageProps<Data>) {
  const { room, reservation } = data ?? {};
  return (
    <Layout title="Detalhes da Reserva">
      <Alert type="error" message={data?.error ?? ""} />
      {room && reservation && (
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 max-w-2xl">
          <div class="mb-4"><StatusBadge status={reservation.status} /></div>
          <p class="mb-2"><span class="font-medium">Sala:</span> {room.name}</p>
          <p class="mb-2"><span class="font-medium">Responsável:</span> {reservation.responsible}</p>
          <p class="mb-2"><span class="font-medium">Início:</span> {formatDateTime(reservation.start_time)}</p>
          <p class="mb-2"><span class="font-medium">Fim:</span> {formatDateTime(reservation.end_time)}</p>
          <p class="mb-4"><span class="font-medium">Descrição:</span> {reservation.description || "—"}</p>
          <div class="flex flex-wrap gap-2">
            {reservation.status !== "cancelled" && (
              <>
                <a
                  href={`/rooms/${room.id}/reservations/${reservation.id}/edit`}
                  class="px-4 py-2 border rounded hover:bg-slate-50"
                >
                  Editar
                </a>
                <form method="POST" class="inline">
                  <input type="hidden" name="_method" value="DELETE" />
                  <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">
                    Cancelar Reserva
                  </button>
                </form>
              </>
            )}
            <a href={`/rooms/${room.id}/reservations`} class="px-4 py-2 text-blue-600 hover:underline">
              Voltar
            </a>
          </div>
        </div>
      )}
    </Layout>
  );
}
