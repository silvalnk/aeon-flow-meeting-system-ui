# frozen_string_literal: true

module App
  module Serializers
    module ReservationSerializer
      module_function

      def serialize(reservation)
        {
          id: reservation.id.value,
          room_id: reservation.room_id,
          start_time: reservation.start_time.iso8601,
          end_time: reservation.end_time.iso8601,
          description: reservation.description,
          responsible: reservation.responsible,
          status: reservation.status
        }
      end

      def serialize_collection(reservations)
        reservations.map { |reservation| serialize(reservation) }
      end
    end
  end
end
