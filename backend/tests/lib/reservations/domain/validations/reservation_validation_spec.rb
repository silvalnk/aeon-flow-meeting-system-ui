# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/domain/validations/reservation_validation'
require_relative '../../../../../src/lib/reservations/domain/validations/reservation_validation_service'

RSpec.describe Reservations::Domain::Validations::ReservationValidation do
  subject(:validator) { described_class.new }

  let(:future_start) { DateTime.now + 2 }
  let(:future_end) { future_start + Rational(1, 24) }

  describe 'validations' do
    it 'passes with valid attributes' do
      result = validator.call(
        room_id: 'room-1',
        start_time: future_start,
        end_time: future_end,
        responsible: 'Maria'
      )
      expect(result).to be_success
    end

    it 'fails when end_time is not after start_time' do
      result = validator.call(
        room_id: 'room-1',
        start_time: future_start,
        end_time: future_start,
        responsible: 'Maria'
      )
      expect(result).to be_failure
      expect(result.errors.to_h).to include(:end_time)
    end

    it 'fails when responsible is missing' do
      result = validator.call(
        room_id: 'room-1',
        start_time: future_start,
        end_time: future_end,
        responsible: ''
      )
      expect(result).to be_failure
      expect(result.errors.to_h).to include(:responsible)
    end

    it 'fails when status is invalid' do
      result = validator.call(
        room_id: 'room-1',
        start_time: future_start,
        end_time: future_end,
        responsible: 'Maria',
        status: 'invalid'
      )
      expect(result).to be_failure
      expect(result.errors.to_h).to include(:status)
    end
  end

  describe 'ReservationValidationService.evaluate_attributes' do
    it 'adds future validation error on create' do
      notification = Reservations::Domain::Validations::ReservationValidationService.evaluate_attributes(
        {
          room_id: 'room-1',
          start_time: DateTime.now - 1,
          end_time: DateTime.now + Rational(1, 24),
          responsible: 'Maria'
        }
      )
      expect(notification.has_errors?).to be true
      expect(notification.error_messages.join).to include('future')
    end

    it 'skips future validation on update' do
      notification = Reservations::Domain::Validations::ReservationValidationService.evaluate_attributes(
        {
          room_id: 'room-1',
          start_time: DateTime.now - 1,
          end_time: DateTime.now + Rational(1, 24),
          responsible: 'Maria'
        },
        for_update: true
      )
      expect(notification.has_errors?).to be false
    end
  end
end
