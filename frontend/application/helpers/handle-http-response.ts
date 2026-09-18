import { Either, Left, Right } from "@shared_domain/either.ts";
import { AppError } from "@shared_domain/app-error.ts";
import { HttpResponse, HttpStatusCode } from "@shared_domain/http-client.ts";

const SUCCESS_CODES = [
  HttpStatusCode.ok,
  HttpStatusCode.noContent,
  201,
];

export const handleHttpResponse = <T>(
  response: HttpResponse,
): Either<AppError, T> => {
  if (SUCCESS_CODES.includes(response.statusCode)) {
    return Right(response.body as T);
  }

  const body = response.body ?? {};
  let message = body.error ?? body.message ??
    (Array.isArray(body.errors) ? body.errors.join(", ") : "Request failed");
  if (response.statusCode === 401 && String(message) === "Unauthorized") {
    message = "Session expired or missing. Log in to continue.";
  }

  return Left({
    message: String(message),
    statusCode: response.statusCode,
    errors: body.errors,
  });
};
