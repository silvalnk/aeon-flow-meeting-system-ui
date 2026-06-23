import { Either, UseCase } from "../../shared_domain/index.ts";
import { LoginResponse, ReservationEntity } from "../entities/index.ts";

export type LoginRequest = { email: string; password: string };
export type LoginResponseEither = Either<{ message: string }, LoginResponse>;
export interface LoginUseCase extends UseCase<LoginRequest, LoginResponseEither> {}

export type ListReservationsRequest = {
  roomId: string;
  status?: string;
  start_time?: string;
  end_time?: string;
  search?: string;
  token?: string | null;
};
export type ListReservationsResponse = Either<{ message: string }, ReservationEntity[]>;
export interface ListReservationsUseCase extends UseCase<ListReservationsRequest, ListReservationsResponse> {}

export type GetReservationRequest = { roomId: string; id: string; token?: string | null };
export type GetReservationResponse = Either<{ message: string }, ReservationEntity>;
export interface GetReservationUseCase extends UseCase<GetReservationRequest, GetReservationResponse> {}

export type CreateReservationRequest = {
  roomId: string;
  start_time: string;
  end_time: string;
  description?: string;
  responsible: string;
  status?: string;
  token?: string | null;
};
export type CreateReservationResponse = Either<{ message: string }, ReservationEntity>;
export interface CreateReservationUseCase extends UseCase<CreateReservationRequest, CreateReservationResponse> {}

export type UpdateReservationRequest = {
  roomId: string;
  id: string;
  start_time?: string;
  end_time?: string;
  description?: string;
  responsible?: string;
  status?: string;
  token?: string | null;
};
export type UpdateReservationResponse = Either<{ message: string }, ReservationEntity>;
export interface UpdateReservationUseCase extends UseCase<UpdateReservationRequest, UpdateReservationResponse> {}

export type CancelReservationRequest = { roomId: string; id: string; token?: string | null };
export type CancelReservationResponse = Either<{ message: string }, void>;
export interface CancelReservationUseCase extends UseCase<CancelReservationRequest, CancelReservationResponse> {}
