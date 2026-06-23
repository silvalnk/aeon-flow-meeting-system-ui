# frozen_string_literal: true

require_relative 'database_helper'
require_relative '../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.shared_context 'with room action integration' do
  let(:rom) { DatabaseHelper.rom }

  before do
    DatabaseHelper.truncate_all!
    unit_of_work = SharedDomain::Infrastructure::UnitOfWork.new(rom)
    allow(Rooms::AppContainer).to receive(:resolve).and_call_original
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.rom').and_return(rom)
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
  end

  after do
    rom.container.disconnect
  end
end

RSpec.shared_context 'with reservation action integration' do
  include_context 'with room action integration'

  before do
    unit_of_work = SharedDomain::Infrastructure::UnitOfWork.new(rom)
    allow(Reservations::AppContainer).to receive(:resolve).and_call_original
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.rom').and_return(rom)
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
  end
end
