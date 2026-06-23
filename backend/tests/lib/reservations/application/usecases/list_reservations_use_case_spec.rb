# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/app_container'
require_relative '../../../../../src/lib/reservations/application/use_cases/list_reservations_use_case'
require_relative '../../../../../src/lib/reservations/application/repositories/reservation_repository'

RSpec.describe Reservations::Application::UseCases::ListReservationsUseCase do
  let(:reservation_repository) { instance_double(Reservations::Application::Repositories::ReservationRepository) }
  let(:use_case) { described_class.new }

  before do
    allow(Reservations::AppContainer).to receive(:resolve).with('reservations.infrastructure.reservation_repository').and_return(reservation_repository)
  end

  describe '#call' do
    it 'returns reservations for a room' do
      reservations = [instance_double(Reservations::Domain::Entities::Reservation)]
      allow(reservation_repository).to receive(:find_all).with('room-1', {}).and_return(reservations)

      result = use_case.call(room_id: 'room-1')

      expect(result).to be_success
      expect(result.value!).to eq(reservations)
    end

    it 'passes filters to repository' do
      allow(reservation_repository).to receive(:find_all).and_return([])

      use_case.call(room_id: 'room-1', status: 'confirmed', search: 'João')

      expect(reservation_repository).to have_received(:find_all).with(
        'room-1',
        hash_including(status: 'confirmed', search: 'João')
      )
    end
  end
end
