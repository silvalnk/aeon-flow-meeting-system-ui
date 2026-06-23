export const AUTH_COOKIE = "auth_token";

export const getAuthToken = (cookieHeader: string | null): string | null => {
  if (!cookieHeader) return null;
  const match = cookieHeader.match(new RegExp(`${AUTH_COOKIE}=([^;]+)`));
  return match ? decodeURIComponent(match[1]) : null;
};

export const buildAuthHeaders = (
  token: string | null,
): Record<string, string> => {
  if (!token) return {};
  return { Authorization: `Bearer ${token}` };
};

export const buildSetAuthCookie = (token: string): string => {
  return `${AUTH_COOKIE}=${encodeURIComponent(token)}; Path=/; HttpOnly; SameSite=Lax; Max-Age=86400`;
};

export const buildClearAuthCookie = (): string => {
  return `${AUTH_COOKIE}=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0`;
};
