import { RoomEntity } from "../domain/entities/index.ts";

type RoomCardProps = {
  room: RoomEntity;
  authenticated?: boolean;
};

export default function RoomCard({ room, authenticated = false }: RoomCardProps) {
  return (
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-5 flex flex-col gap-3">
      <div>
        <h2 class="text-lg font-semibold">{room.name}</h2>
        <p class="text-sm text-slate-600">{room.location}</p>
      </div>
      <p class="text-sm">
        <span class="font-medium">Capacity:</span> {room.capacity} people
      </p>
      <div class="flex flex-wrap gap-2 mt-auto">
        <a
          href={`/rooms/${room.id}`}
          class="px-3 py-1.5 text-sm bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Details
        </a>
        <a
          href={`/rooms/${room.id}/reservations`}
          class="px-3 py-1.5 text-sm bg-slate-100 text-slate-800 rounded hover:bg-slate-200"
        >
          Reservations
        </a>
        {authenticated && (
          <a
            href={`/rooms/${room.id}/edit`}
            class="px-3 py-1.5 text-sm border border-slate-300 rounded hover:bg-slate-50"
          >
            Edit
          </a>
        )}
      </div>
    </div>
  );
}
