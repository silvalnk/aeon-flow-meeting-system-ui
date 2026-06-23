import { HttpClient } from "../../shared_domain/http-client.ts";
import { buildAuthHeaders } from "../../infrastructure/auth/token-storage.ts";
import { handleHttpResponse } from "../helpers/handle-http-response.ts";
import {
  ListRoomsRequest,
  ListRoomsResponse,
  ListRoomsUseCase,
  GetRoomRequest,
  GetRoomResponse,
  GetRoomUseCase,
  CreateRoomRequest,
  CreateRoomResponse,
  CreateRoomUseCase,
  UpdateRoomRequest,
  UpdateRoomResponse,
  UpdateRoomUseCase,
  DeleteRoomRequest,
  DeleteRoomResponse,
  DeleteRoomUseCase,
} from "../../domain/usecases/room-usecases.ts";
import { RoomEntity } from "../../domain/entities/index.ts";

export class HttpListRoomsUseCase implements ListRoomsUseCase {
  constructor(private readonly url: string, private readonly httpClient: HttpClient) {}

  async execute(params: ListRoomsRequest): Promise<ListRoomsResponse> {
    const query = params.search ? `?search=${encodeURIComponent(params.search)}` : "";
    const response = await this.httpClient.request({
      url: `${this.url}${query}`,
      method: "get",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<RoomEntity[]>(response);
  }
}

export class HttpGetRoomUseCase implements GetRoomUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: GetRoomRequest): Promise<GetRoomResponse> {
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${params.id}`,
      method: "get",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<RoomEntity>(response);
  }
}

export class HttpCreateRoomUseCase implements CreateRoomUseCase {
  constructor(private readonly url: string, private readonly httpClient: HttpClient) {}

  async execute(params: CreateRoomRequest): Promise<CreateRoomResponse> {
    const { token, ...body } = params;
    const response = await this.httpClient.request({
      url: this.url,
      method: "post",
      body,
      headers: buildAuthHeaders(token ?? null),
    });
    return handleHttpResponse<RoomEntity>(response);
  }
}

export class HttpUpdateRoomUseCase implements UpdateRoomUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: UpdateRoomRequest): Promise<UpdateRoomResponse> {
    const { id, token, ...body } = params;
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${id}`,
      method: "put",
      body,
      headers: buildAuthHeaders(token ?? null),
    });
    return handleHttpResponse<RoomEntity>(response);
  }
}

export class HttpDeleteRoomUseCase implements DeleteRoomUseCase {
  constructor(private readonly baseUrl: string, private readonly httpClient: HttpClient) {}

  async execute(params: DeleteRoomRequest): Promise<DeleteRoomResponse> {
    const response = await this.httpClient.request({
      url: `${this.baseUrl}/${params.id}`,
      method: "delete",
      headers: buildAuthHeaders(params.token ?? null),
    });
    return handleHttpResponse<void>(response);
  }
}
