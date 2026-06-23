# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/infrastructure/repositories/sqlite_reservation_repository'
require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../../../support/database_helper'

RSpec.describe Reservations::Infrastructure::Repositories::SqliteReservationRepository do
  let(:rom) { DatabaseHelper.rom }
  let(:repository) { described_class.new }
  let(:room) { DatabaseHelper.create_room }

  before do
    DatabaseHelper.truncate_all!
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.rom').and_return(rom)
    @room = DatabaseHelper.create_room
  end

  after do
    rom.container.disconnect
  end

  def build_reservation(overrides = {})
    start_time = DateTime.now + 2
    Reservations::Domain::Entities::Reservation.new({
      room_id: @room.id.value,
      start_time: start_time,
      end_time: start_time + Rational(1, 24),
      responsible: 'João Silva',
      status: 'pending'
    }.merge(overrides))
  end

  describe '#add' do
    it 'persists a new reservation' do
      reservation = build_reservation

      expect {
        repository.add(reservation)
      }.to change { rom[:reservations].count }.by(1)
    end
  end

  describe '#find_by_id' do
    it 'returns the reservation when it exists' do
      reservation = build_reservation
      repository.add(reservation)

      found = repository.find_by_id(@room.id.value, reservation.id.value)

      expect(found.responsible).to eq('João Silva')
    end

    it 'returns nil when reservation does not exist' do
      expect(repository.find_by_id(@room.id.value, 'missing')).to be_nil
    end
  end

  describe '#find_all' do
    it 'returns reservations for a room' do
      repository.add(build_reservation)
      repository.add(build_reservation(responsible: 'Maria'))

      results = repository.find_all(@room.id.value)

      expect(results.size).to eq(2)
    end

    it 'filters by status' do
      repository.add(build_reservation(status: 'confirmed'))
      repository.add(build_reservation(status: 'pending'))

      results = repository.find_all(@room.id.value, status: 'confirmed')

      expect(results.size).to eq(1)
      expect(results.first.status).to eq('confirmed')
    end

    it 'filters by search on responsible' do
      repository.add(build_reservation(responsible: 'João Silva'))
      repository.add(build_reservation(responsible: 'Maria Souza'))

      results = repository.find_all(@room.id.value, search: 'Maria')

      expect(results.size).to eq(1)
      expect(results.first.responsible).to eq('Maria Souza')
    end
  end

  describe '#update' do
    it 'updates reservation attributes' do
      reservation = build_reservation
      repository.add(reservation)

      updated = Reservations::Domain::Entities::Reservation.new(
        id: reservation.id.value,
        room_id: @room.id.value,
        start_time: reservation.start_time,
        end_time: reservation.end_time,
        responsible: 'Pedro',
        status: 'confirmed',
        persisted: true
      )
      repository.update(updated)

      found = repository.find_by_id(@room.id.value, reservation.id.value)
      expect(found.responsible).to eq('Pedro')
      expect(found.status).to eq('confirmed')
    end
  end

  describe '#has_overlapping?' do
    it 'detects overlapping reservations' do
      start_time = DateTime.now + 2
      end_time = start_time + Rational(2, 24)
      repository.add(build_reservation(start_time: start_time, end_time: end_time))

      overlapping_start = start_time + Rational(1, 24)
      overlapping_end = overlapping_start + Rational(1, 24)

      expect(repository.has_overlapping?(@room.id.value, overlapping_start, overlapping_end)).to be true
    end

    it 'ignores cancelled reservations' do
      start_time = DateTime.now + 2
      end_time = start_time + Rational(2, 24)
      repository.add(build_reservation(start_time: start_time, end_time: end_time, status: 'cancelled'))

      expect(repository.has_overlapping?(@room.id.value, start_time + Rational(1, 24), end_time)).to be false
    end

    it 'excludes a reservation by id when checking overlap' do
      reservation = build_reservation
      repository.add(reservation)

      expect(
        repository.has_overlapping?(
          @room.id.value,
          reservation.start_time,
          reservation.end_time,
          exclude_id: reservation.id.value
        )
      ).to be false
    end
  end
end
