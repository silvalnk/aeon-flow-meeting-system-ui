import { ReservationEntity } from "../domain/entities/index.ts";

type StatusBadgeProps = {
  status: ReservationEntity["status"];
};

const colors: Record<ReservationEntity["status"], string> = {
  confirmed: "bg-green-100 text-green-800",
  pending: "bg-yellow-100 text-yellow-800",
  cancelled: "bg-red-100 text-red-800",
};

const labels: Record<ReservationEntity["status"], string> = {
  confirmed: "Confirmada",
  pending: "Pendente",
  cancelled: "Cancelada",
};

export default function StatusBadge({ status }: StatusBadgeProps) {
  return (
    <span class={`inline-block px-2 py-0.5 rounded text-xs font-medium ${colors[status]}`}>
      {labels[status]}
    </span>
  );
}
