# frozen_string_literal: true

require_relative '../../../src/app/actions/update_reservation_action'
require_relative '../../../src/lib/reservations/infrastructure/repositories/sqlite_reservation_repository'
require_relative '../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::UpdateReservationAction do
  include_context 'with reservation action integration'

  let(:action) { described_class.new }
  let(:repository) { Reservations::Infrastructure::Repositories::SqliteReservationRepository.new }
  let(:room) { DatabaseHelper.create_room }

  def create_reservation
    start_time = DateTime.now + 2
    reservation = Reservations::Domain::Entities::Reservation.new(
      room_id: room.id.value,
      start_time: start_time,
      end_time: start_time + Rational(1, 24),
      responsible: 'Maria'
    )
    repository.add(reservation)
    reservation
  end

  describe '#call' do
    it 'returns 200 when reservation is updated' do
      reservation = create_reservation
      new_start = DateTime.now + 3
      new_end = new_start + Rational(1, 24)

      result = action.call(
        room_id: room.id.value,
        id: reservation.id.value,
        start_time: new_start,
        end_time: new_end,
        responsible: 'Pedro'
      )

      expect(result[:status]).to eq(200)
      expect(result[:body][:responsible]).to eq('Pedro')
    end

    it 'returns 404 when reservation does not exist' do
      start_time = DateTime.now + 3

      result = action.call(
        room_id: room.id.value,
        id: '00000000-0000-0000-0000-000000000000',
        start_time: start_time,
        end_time: start_time + Rational(1, 24),
        responsible: 'Pedro'
      )

      expect(result[:status]).to eq(404)
    end
  end
end
