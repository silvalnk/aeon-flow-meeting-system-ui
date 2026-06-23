export const makeApiUrl = (path: string): string => {
  const baseUrl = Deno.env.get("API_URL") ?? "http://localhost:9292/api/v1";
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  return `${baseUrl}${normalizedPath}`;
};
