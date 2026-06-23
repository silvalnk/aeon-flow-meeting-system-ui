# frozen_string_literal: true

require_relative '../../../src/app/actions/list_reservations_action'
require_relative '../../../src/lib/reservations/infrastructure/repositories/sqlite_reservation_repository'
require_relative '../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::ListReservationsAction do
  include_context 'with reservation action integration'

  let(:action) { described_class.new }
  let(:repository) { Reservations::Infrastructure::Repositories::SqliteReservationRepository.new }
  let(:room) { DatabaseHelper.create_room }

  def create_reservation(responsible: 'Maria')
    start_time = DateTime.now + 2
    reservation = Reservations::Domain::Entities::Reservation.new(
      room_id: room.id.value,
      start_time: start_time,
      end_time: start_time + Rational(1, 24),
      responsible: responsible
    )
    repository.add(reservation)
    reservation
  end

  describe '#call' do
    it 'returns 200 with reservations for a room' do
      create_reservation
      create_reservation(responsible: 'João')

      result = action.call(room_id: room.id.value)

      expect(result[:status]).to eq(200)
      expect(result[:body].length).to eq(2)
    end

    it 'filters by search on responsible' do
      create_reservation(responsible: 'Maria')
      create_reservation(responsible: 'João')

      result = action.call(room_id: room.id.value, search: 'João')

      expect(result[:status]).to eq(200)
      expect(result[:body].length).to eq(1)
      expect(result[:body].first[:responsible]).to eq('João')
    end
  end
end
