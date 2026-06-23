# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/domain/validations/room_validation'

RSpec.describe Rooms::Domain::Validations::RoomValidation do
  subject(:validator) { described_class.new }

  describe 'validations' do
    context 'when all attributes are valid' do
      it 'passes validation' do
        sut = validator.call({
          name: 'Conference Room A',
          capacity: 10,
          location: 'Building 1, Floor 3'
        })
        expect(sut).to be_success
      end
    end

    context 'when name is missing' do
      it 'fails validation' do
        sut = validator.call({
          name: '',
          capacity: 10,
          location: 'Building 1, Floor 3'
        })
        expect(sut).to be_failure
        expect(sut.errors.to_h).to include(:name)
      end
    end

    context 'when capacity is less than or equal to 0' do
      it 'fails validation' do
        sut = validator.call({
          name: 'Conference Room B',
          capacity: -1,
          location: 'Building 2, Floor 1'
        })
        expect(sut).to be_failure
        expect(sut.errors.to_h).to include(:capacity)
      end
    end

    context 'when location is missing' do
      it 'fails validation' do
        sut = validator.call({
          name: 'Conference Room C',
          capacity: 5,
          location: ''
        })
        expect(sut).to be_failure
        expect(sut.errors.to_h).to include(:location)
      end
    end

    context 'when name exceeds 100 characters' do
      it 'fails validation' do
        sut = validator.call({
          name: 'a' * 101,
          capacity: 5,
          location: 'Building 1'
        })
        expect(sut).to be_failure
        expect(sut.errors.to_h).to include(:name)
      end
    end
  end
end
