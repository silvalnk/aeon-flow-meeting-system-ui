# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/domain/errors/reservation_validation_error'
require_relative '../../../../../src/lib/shared_domain/domain/notification'

RSpec.describe Reservations::Domain::Errors::ReservationValidationError do
  it 'wraps notification errors' do
    notification = SharedDomain::Domain::Notification.new
    notification.add_error(:responsible, 'must be filled')

    error = described_class.new(notification)

    expect(error).to be_a(StandardError)
    expect(error.message).to include('responsible')
  end
end

RSpec.describe Reservations::Domain::Errors::RoomNotAvailableError do
  it 'has a descriptive message' do
    expect(described_class.new.message).to include('not available')
  end
end

RSpec.describe Reservations::Domain::Errors::CancellationNotAllowedError do
  it 'has a descriptive message' do
    expect(described_class.new.message).to include('24 hours')
  end
end
