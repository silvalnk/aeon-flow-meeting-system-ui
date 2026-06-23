import { Either, UseCase } from "../../shared_domain/index.ts";
import { RoomEntity } from "../entities/index.ts";

export type ListRoomsRequest = { search?: string; token?: string | null };
export type ListRoomsResponse = Either<{ message: string }, RoomEntity[]>;
export interface ListRoomsUseCase extends UseCase<ListRoomsRequest, ListRoomsResponse> {}

export type GetRoomRequest = { id: string; token?: string | null };
export type GetRoomResponse = Either<{ message: string }, RoomEntity>;
export interface GetRoomUseCase extends UseCase<GetRoomRequest, GetRoomResponse> {}

export type CreateRoomRequest = {
  name: string;
  capacity: number;
  location: string;
  token?: string | null;
};
export type CreateRoomResponse = Either<{ message: string }, RoomEntity>;
export interface CreateRoomUseCase extends UseCase<CreateRoomRequest, CreateRoomResponse> {}

export type UpdateRoomRequest = {
  id: string;
  name: string;
  capacity: number;
  location: string;
  token?: string | null;
};
export type UpdateRoomResponse = Either<{ message: string }, RoomEntity>;
export interface UpdateRoomUseCase extends UseCase<UpdateRoomRequest, UpdateRoomResponse> {}

export type DeleteRoomRequest = { id: string; token?: string | null };
export type DeleteRoomResponse = Either<{ message: string }, void>;
export interface DeleteRoomUseCase extends UseCase<DeleteRoomRequest, DeleteRoomResponse> {}
