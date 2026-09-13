import Layout from "@components/Layout.tsx";

export default function Error404() {
  return (
    <Layout title="Página não encontrada">
      <p class="text-slate-600 mb-4">
        O endereço que você abriu não existe neste sistema.
      </p>
      <a href="/rooms" class="text-blue-600 hover:underline">Voltar para as salas</a>
    </Layout>
  );
}
