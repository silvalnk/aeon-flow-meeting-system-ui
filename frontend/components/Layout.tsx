import { ComponentChildren } from "preact";

type LayoutProps = {
  children: ComponentChildren;
  title?: string;
};

export default function Layout({ children, title }: LayoutProps) {
  return (
    <div class="min-h-screen bg-slate-50 text-slate-900">
      <header class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-6xl mx-auto px-4 py-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <a href="/rooms" class="text-xl font-bold text-blue-600 hover:text-blue-700">
            Aeon Flow
          </a>
          <nav class="flex flex-wrap gap-4 text-sm font-medium">
            <a href="/rooms" class="hover:text-blue-600">Salas</a>
            <a href="/rooms/new" class="hover:text-blue-600">Nova Sala</a>
            <a href="/login" class="hover:text-blue-600">Login</a>
          </nav>
        </div>
      </header>
      <main class="max-w-6xl mx-auto px-4 py-8">
        {title && <h1 class="text-2xl font-bold mb-6">{title}</h1>}
        {children}
      </main>
    </div>
  );
}
