import { formatDateTime } from "../shared_domain/formatters.ts";
import { ReservationEntity } from "../domain/entities/index.ts";
import StatusBadge from "./StatusBadge.tsx";

type ReservationRowProps = {
  reservation: ReservationEntity;
  roomId: string;
  roomName?: string;
  canEdit?: boolean;
};

export default function ReservationRow(
  { reservation, roomId, roomName, canEdit = false }: ReservationRowProps,
) {
  return (
    <tr class="border-b border-slate-100 hover:bg-slate-50">
      {roomName && <td class="px-4 py-3">{roomName}</td>}
      <td class="px-4 py-3">{reservation.responsible}</td>
      <td class="px-4 py-3 text-sm">{formatDateTime(reservation.start_time)}</td>
      <td class="px-4 py-3 text-sm">{formatDateTime(reservation.end_time)}</td>
      <td class="px-4 py-3"><StatusBadge status={reservation.status} /></td>
      <td class="px-4 py-3 text-sm text-slate-600">{reservation.description ?? "—"}</td>
      <td class="px-4 py-3">
        <div class="flex gap-2">
          <a
            href={`/rooms/${roomId}/reservations/${reservation.id}`}
            class="text-blue-600 hover:underline text-sm"
          >
            Ver
          </a>
          {canEdit && reservation.status !== "cancelled" && (
            <a
              href={`/rooms/${roomId}/reservations/${reservation.id}/edit`}
              class="text-slate-600 hover:underline text-sm"
            >
              Editar
            </a>
          )}
        </div>
      </td>
    </tr>
  );
}
