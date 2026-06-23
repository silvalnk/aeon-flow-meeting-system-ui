# frozen_string_literal: true

module Reservations
  module Application
    module Repositories
      class ReservationRepository
        def add(entity)
          raise NotImplementedError
        end

        def find_all(_room_id = nil, _filters = {})
          raise NotImplementedError
        end

        def find_by_id(room_id, id)
          raise NotImplementedError
        end

        def update(entity)
          raise NotImplementedError
        end

        def has_overlapping?(room_id, start_time, end_time, exclude_id: nil)
          raise NotImplementedError
        end
      end
    end
  end
end
