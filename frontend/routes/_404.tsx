import Layout from "@components/Layout.tsx";

export default function Error404() {
  return (
    <Layout title="Page not found">
      <p class="text-slate-600 mb-4">
        The address you opened does not exist in this system.
      </p>
      <a href="/rooms" class="text-blue-600 hover:underline">Back to rooms</a>
    </Layout>
  );
}
