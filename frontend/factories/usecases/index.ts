import { makeApiUrl } from "../http/api-url-factory.ts";
import { makeAxiosHttpClient } from "../http/axios-http-client-factory.ts";
import {
  HttpListRoomsUseCase,
  HttpGetRoomUseCase,
  HttpCreateRoomUseCase,
  HttpUpdateRoomUseCase,
  HttpDeleteRoomUseCase,
} from "../../application/usecases/http-room-usecases.ts";
import {
  HttpLoginUseCase,
  HttpListReservationsUseCase,
  HttpGetReservationUseCase,
  HttpCreateReservationUseCase,
  HttpUpdateReservationUseCase,
  HttpCancelReservationUseCase,
} from "../../application/usecases/http-reservation-usecases.ts";

const httpClient = makeAxiosHttpClient();

export const makeHttpListRoomsUseCase = () =>
  new HttpListRoomsUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpGetRoomUseCase = () =>
  new HttpGetRoomUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpCreateRoomUseCase = () =>
  new HttpCreateRoomUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpUpdateRoomUseCase = () =>
  new HttpUpdateRoomUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpDeleteRoomUseCase = () =>
  new HttpDeleteRoomUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpLoginUseCase = () =>
  new HttpLoginUseCase(makeApiUrl("/auth/login"), httpClient);

export const makeHttpListReservationsUseCase = () =>
  new HttpListReservationsUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpListAllReservationsUseCase = () =>
  new HttpListReservationsUseCase(makeApiUrl("/reservations"), httpClient);

export const makeHttpGetReservationUseCase = () =>
  new HttpGetReservationUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpCreateReservationUseCase = () =>
  new HttpCreateReservationUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpUpdateReservationUseCase = () =>
  new HttpUpdateReservationUseCase(makeApiUrl("/rooms"), httpClient);

export const makeHttpCancelReservationUseCase = () =>
  new HttpCancelReservationUseCase(makeApiUrl("/rooms"), httpClient);
