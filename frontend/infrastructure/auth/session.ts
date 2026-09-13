import { getTokenFromRequest } from "./token-storage.ts";

export const isAuthenticated = (request: Request): boolean =>
  Boolean(getTokenFromRequest(request));

export const safeRedirectPath = (value: string | null | undefined): string => {
  if (!value) return "/rooms";
  if (!value.startsWith("/") || value.startsWith("//")) return "/rooms";
  if (value.startsWith("/login") || value.startsWith("/logout")) return "/rooms";
  return value;
};

export const loginRedirect = (request: Request): Response => {
  const url = new URL(request.url);
  const next = safeRedirectPath(`${url.pathname}${url.search}`);
  return new Response(null, {
    status: 302,
    headers: { Location: `/login?redirect=${encodeURIComponent(next)}` },
  });
};

export const requireAuth = (request: Request): Response | null => {
  if (isAuthenticated(request)) return null;
  return loginRedirect(request);
};

export const redirectTo = (
  location: string,
  extraHeaders: Record<string, string> = {},
): Response => {
  return new Response(null, {
    status: 302,
    headers: { Location: location, ...extraHeaders },
  });
};

export const unauthorizedRedirect = (
  request: Request,
  statusCode?: number,
): Response | null => {
  if (statusCode === 401) return loginRedirect(request);
  return null;
};
