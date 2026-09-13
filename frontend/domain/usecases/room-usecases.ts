import { Either, UseCase } from "../../shared_domain/index.ts";
import { AppError } from "../../shared_domain/app-error.ts";
import { RoomEntity } from "../entities/index.ts";

export type ListRoomsRequest = { search?: string; token?: string | null };
export type ListRoomsResponse = Either<AppError, RoomEntity[]>;
export interface ListRoomsUseCase extends UseCase<ListRoomsRequest, ListRoomsResponse> {}

export type GetRoomRequest = { id: string; token?: string | null };
export type GetRoomResponse = Either<AppError, RoomEntity>;
export interface GetRoomUseCase extends UseCase<GetRoomRequest, GetRoomResponse> {}

export type CreateRoomRequest = {
  name: string;
  capacity: number;
  location: string;
  token?: string | null;
};
export type CreateRoomResponse = Either<AppError, RoomEntity>;
export interface CreateRoomUseCase extends UseCase<CreateRoomRequest, CreateRoomResponse> {}

export type UpdateRoomRequest = {
  id: string;
  name: string;
  capacity: number;
  location: string;
  token?: string | null;
};
export type UpdateRoomResponse = Either<AppError, RoomEntity>;
export interface UpdateRoomUseCase extends UseCase<UpdateRoomRequest, UpdateRoomResponse> {}

export type DeleteRoomRequest = { id: string; token?: string | null };
export type DeleteRoomResponse = Either<AppError, void>;
export interface DeleteRoomUseCase extends UseCase<DeleteRoomRequest, DeleteRoomResponse> {}
