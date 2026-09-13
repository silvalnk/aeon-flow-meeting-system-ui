import { HttpClient } from "../../shared_domain/http-client.ts";
import { buildAuthHeaders } from "../../infrastructure/auth/token-storage.ts";
import { handleHttpResponse } from "../helpers/handle-http-response.ts";
import {
  LoginRequest,
  LoginResponseEither,
  LoginUseCase,
  ListReservationsRequest,
  ListReservationsResponse,
  ListReservationsUseCase,
  GetReservationRequest,
  GetReservationResponse,
  GetReservationUseCase,
  CreateReservationRequest,
  CreateReservationResponse,
  CreateReservationUseCase,
  UpdateReservationRequest,
  UpdateReservationResponse,
  UpdateReservationUseCase,
  CancelReservationRequest,
  CancelReservationResponse,
  CancelReservationUseCase,
} from "../../domain/usecases/reservation-usecases.ts";
import { LoginResponse, ReservationEntity } from "../../domain/entities/index.ts";

export class HttpLoginUseCase implements LoginUseCase {
  constructor(private readonly url: string, private readonly httpClient: HttpClient) {}

  async execute(params: LoginRequest): Promise<LoginResponseEither> {
    const response = await this.httpClient.request({
      url: this.url,
      method: "post",
      body: params,
    });
    return handleHttpResponse<LoginResponse>(response);
  }
}

export class HttpListReservationsUseCase implements ListReservationsUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: ListReservationsRequest): Promise<ListReservationsResponse> {
    const query = new URLSearchParams();
    if (params.status) query.set("status", params.status);
    if (params.start_time) query.set("start_time", params.start_time);
    if (params.end_time) query.set("end_time", params.end_time);
    if (params.search) query.set("search", params.search);
    const qs = query.toString();
    const url = params.roomId
      ? `${this.baseUrl}/${params.roomId}/reservations${qs ? `?${qs}` : ""}`
      : `${this.baseUrl}${qs ? `?${qs}` : ""}`;

    const response = await this.httpClient.request({
      url,
      method: "get",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<ReservationEntity[]>(response);
  }
}

export class HttpGetReservationUseCase implements GetReservationUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: GetReservationRequest): Promise<GetReservationResponse> {
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${params.roomId}/reservations/${params.id}`,
      method: "get",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<ReservationEntity>(response);
  }
}

export class HttpCreateReservationUseCase implements CreateReservationUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: CreateReservationRequest): Promise<CreateReservationResponse> {
    const { roomId, token, ...body } = params;
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${roomId}/reservations`,
      method: "post",
      body,
      headers: buildAuthHeaders(token ?? null),
    });
    return handleHttpResponse<ReservationEntity>(response);
  }
}

export class HttpUpdateReservationUseCase implements UpdateReservationUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: UpdateReservationRequest): Promise<UpdateReservationResponse> {
    const { roomId, id, token, ...body } = params;
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${roomId}/reservations/${id}`,
      method: "put",
      body,
      headers: buildAuthHeaders(token ?? null),
    });
    return handleHttpResponse<ReservationEntity>(response);
  }
}

export class HttpCancelReservationUseCase implements CancelReservationUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: CancelReservationRequest): Promise<CancelReservationResponse> {
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${params.roomId}/reservations/${params.id}`,
      method: "delete",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<void>(response);
  }
}
