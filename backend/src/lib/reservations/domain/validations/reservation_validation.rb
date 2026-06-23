# frozen_string_literal: true

require_relative '../../../shared_domain/domain/validation'

module Reservations
  module Domain
    module Validations
      class ReservationValidation < SharedDomain::Domain::Validation
        STATUSES = %w[confirmed pending cancelled].freeze

        params do
          required(:room_id).filled(:string)
          required(:start_time)
          required(:end_time)
          optional(:description).maybe(:string)
          required(:responsible).filled(:string, max_size?: 100)
          optional(:status).maybe(:string, included_in?: STATUSES)
        end

        rule(:start_time, :end_time) do
          begin
            start_time = values[:start_time].is_a?(DateTime) ? values[:start_time] : DateTime.parse(values[:start_time].to_s)
            end_time = values[:end_time].is_a?(DateTime) ? values[:end_time] : DateTime.parse(values[:end_time].to_s)

            key(:end_time).failure('must be after start_time') if end_time <= start_time
          rescue ArgumentError
            key(:start_time).failure('must be a valid datetime')
          end
        end
      end
    end
  end
end
