import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "@components/Layout.tsx";
import Alert from "@components/Alert.tsx";
import RoomCard from "@components/RoomCard.tsx";
import { makeHttpListRoomsUseCase } from "@factories/usecases/index.ts";
import { isLeft } from "@shared_domain/either.ts";
import { getTokenFromRequest } from "@infrastructure/auth/token-storage.ts";
import { isAuthenticated } from "@infrastructure/auth/session.ts";
import { RoomEntity } from "@domain/entities/index.ts";

interface Data {
  rooms: RoomEntity[];
  search?: string;
  error?: string;
  authenticated: boolean;
}

export const handler: Handlers<Data> = {
  async GET(req, ctx) {
    const url = new URL(req.url);
    const search = url.searchParams.get("search") ?? undefined;
    const token = getTokenFromRequest(req);
    const authenticated = isAuthenticated(req);
    const result = await makeHttpListRoomsUseCase().execute({ search, token });

    if (isLeft(result)) {
      return ctx.render({ rooms: [], search, error: result.value.message, authenticated });
    }

    return ctx.render({ rooms: result.value, search, authenticated });
  },
};

export default function RoomsPage({ data }: PageProps<Data>) {
  const authenticated = data?.authenticated ?? false;
  return (
    <Layout title="Salas de Reunião" authenticated={authenticated}>
      <Alert type="error" message={data?.error ?? ""} />
      <form method="GET" class="mb-6 flex flex-col sm:flex-row gap-2">
        <input
          type="search"
          name="search"
          value={data?.search ?? ""}
          placeholder="Buscar por nome..."
          class="flex-1 border border-slate-300 rounded px-3 py-2"
        />
        <button type="submit" class="px-4 py-2 bg-slate-800 text-white rounded hover:bg-slate-900">
          Buscar
        </button>
        {authenticated && (
          <a href="/rooms/new" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-center">
            Nova Sala
          </a>
        )}
      </form>
      {data?.rooms.length === 0
        ? <p class="text-slate-600">Nenhuma sala encontrada.</p>
        : (
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {data?.rooms.map((room) => (
              <RoomCard key={room.id} room={room} authenticated={authenticated} />
            ))}
          </div>
        )}
    </Layout>
  );
}
