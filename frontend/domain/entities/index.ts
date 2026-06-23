export type RoomEntity = {
  id: string;
  name: string;
  capacity: number;
  location: string;
};

export type ReservationStatus = "confirmed" | "pending" | "cancelled";

export type ReservationEntity = {
  id: string;
  room_id: string;
  start_time: string;
  end_time: string;
  description?: string;
  responsible: string;
  status: ReservationStatus;
};

export type AuthUser = {
  id: string;
  email: string;
  name: string;
};

export type LoginResponse = {
  token: string;
  user: AuthUser;
};
