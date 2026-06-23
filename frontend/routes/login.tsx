import { Handlers, PageProps } from "$fresh/server.ts";
import Layout from "../../components/Layout.tsx";
import Alert from "../../components/Alert.tsx";
import { makeHttpLoginUseCase } from "../../main/factories/usecases/index.ts";
import { isLeft } from "../../shared_domain/either.ts";
import { buildSetAuthCookie } from "../../infrastructure/auth/token-storage.ts";

interface Data {
  error?: string;
}

export const handler: Handlers<Data> = {
  async POST(req, ctx) {
    const form = await req.formData();
    const result = await makeHttpLoginUseCase().execute({
      email: String(form.get("email")),
      password: String(form.get("password")),
    });

    if (isLeft(result)) {
      return ctx.render({ error: result.value.message });
    }

    return ctx.render(null, {
      headers: {
        Location: "/rooms",
        "Set-Cookie": buildSetAuthCookie(result.value.token),
      },
      status: 302,
    });
  },
};

export default function LoginPage({ data }: PageProps<Data>) {
  return (
    <Layout title="Login">
      <Alert type="error" message={data?.error ?? ""} />
      <form method="POST" class="max-w-md bg-white p-6 rounded-lg shadow-sm border border-slate-200">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="email">E-mail</label>
          <input
            id="email"
            name="email"
            type="email"
            required
            class="w-full border border-slate-300 rounded px-3 py-2"
            placeholder="admin@aeonflow.com"
          />
        </div>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1" for="password">Senha</label>
          <input
            id="password"
            name="password"
            type="password"
            required
            class="w-full border border-slate-300 rounded px-3 py-2"
          />
        </div>
        <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700">
          Entrar
        </button>
        <p class="text-xs text-slate-500 mt-4">Demo: admin@aeonflow.com / admin123</p>
      </form>
    </Layout>
  );
}
