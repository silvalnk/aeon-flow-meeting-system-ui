import { getAuthToken } from "../infrastructure/auth/token-storage.ts";

export const getTokenFromRequest = (request: Request): string | null => {
  return getAuthToken(request.headers.get("cookie"));
};

export const requireAuth = (request: Request): string | null => {
  return getTokenFromRequest(request);
};
