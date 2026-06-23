# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/infrastructure/mappers/reservation_mapper'
require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'

RSpec.describe Reservations::Infrastructure::Mappers::ReservationMapper do
  let(:start_time) { DateTime.now + 2 }
  let(:end_time) { start_time + Rational(1, 24) }
  let(:reservation_id) { '550e8400-e29b-41d4-a716-446655440000' }
  let(:room_id) { '660e8400-e29b-41d4-a716-446655440001' }

  describe '.to_entity' do
    it 'maps a DAO hash with DateTime values' do
      dao = {
        id: reservation_id,
        room_id: room_id,
        start_time: start_time,
        end_time: end_time,
        description: 'Meeting',
        responsible: 'Maria',
        status: 'pending'
      }

      entity = described_class.to_entity(dao)

      expect(entity.responsible).to eq('Maria')
      expect(entity.start_time).to eq(start_time)
      expect(entity.room_id).to eq(room_id)
    end

    it 'coerces Time values to DateTime' do
      dao = {
        id: reservation_id,
        room_id: room_id,
        start_time: start_time.to_time,
        end_time: end_time.to_time,
        description: nil,
        responsible: 'Maria',
        status: 'pending'
      }

      entity = described_class.to_entity(dao)

      expect(entity.start_time).to be_a(DateTime)
      expect(entity.end_time).to be_a(DateTime)
    end
  end

  describe '.to_dao' do
    it 'maps a reservation entity to a DAO hash' do
      reservation = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: start_time,
        end_time: end_time,
        responsible: 'Maria'
      )

      dao = described_class.to_dao(reservation)

      expect(dao[:room_id]).to eq('room-1')
      expect(dao[:responsible]).to eq('Maria')
      expect(dao[:status]).to eq('pending')
    end
  end

  describe '.coerce_datetime' do
    it 'returns DateTime unchanged' do
      expect(described_class.coerce_datetime(start_time)).to eq(start_time)
    end

    it 'converts Time to DateTime' do
      result = described_class.coerce_datetime(start_time.to_time)

      expect(result).to be_a(DateTime)
    end
  end
end
