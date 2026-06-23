# frozen_string_literal: true

require_relative '../../app_container'
require_relative '../../application/repositories/reservation_repository'
require_relative '../mappers/reservation_mapper'

module Reservations
  module Infrastructure
    module Repositories
      class SqliteReservationRepository < Reservations::Application::Repositories::ReservationRepository
        def initialize
          @rom = Reservations::AppContainer.resolve('infrastructure.rom')
          super
        end

        def add(entity)
          dao = Mappers::ReservationMapper.to_dao(entity)
          @rom[:reservations].command(:create).call(dao)
        end

        def find_all(room_id = nil, filters = {})
          relation = if present?(room_id)
                       @rom[:reservations].where(room_id: room_id)
                     else
                       @rom[:reservations]
                     end
          relation = relation.where(status: filters[:status]) if filters[:status]
          relation = relation.where { start_time >= filters[:start_time] } if filters[:start_time]
          relation = relation.where { end_time <= filters[:end_time] } if filters[:end_time]
          relation = relation.where(Sequel.like(:responsible, "%#{filters[:search]}%")) if filters[:search]

          relation.to_a.map { |row| Mappers::ReservationMapper.to_entity(row) }
        end

        def present?(value)
          !value.nil? && value.to_s.strip != ''
        end

        private :present?

        def find_by_id(room_id, id)
          row = @rom[:reservations].where(room_id: room_id, id: id).one
          return nil unless row

          Mappers::ReservationMapper.to_entity(row)
        end

        def update(entity)
          dao = Mappers::ReservationMapper.to_dao(entity)
          @rom[:reservations].by_pk(entity.id.value).command(:update).call(
            start_time: dao[:start_time],
            end_time: dao[:end_time],
            description: dao[:description],
            responsible: dao[:responsible],
            status: dao[:status]
          )
        end

        def has_overlapping?(room_id, start_time, end_time, exclude_id: nil)
          st = start_time
          et = end_time
          relation = @rom[:reservations].where(room_id: room_id)
          relation = relation.exclude(status: 'cancelled')
          relation = relation.exclude(id: exclude_id) if exclude_id

          relation.where { (start_time < et) & (end_time > st) }.count.positive?
        end
      end
    end
  end
end
