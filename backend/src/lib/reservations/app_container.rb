# frozen_string_literal: true

require 'dry-auto_inject'

require_relative '../shared_domain/container'
require_relative 'infrastructure/repositories/sqlite_reservation_repository'

module Reservations
  class AppContainer < SharedDomain::Container
    namespace :reservations do
      namespace :infrastructure do
        register(:reservation_repository) { Reservations::Infrastructure::Repositories::SqliteReservationRepository.new }
      end
    end

    Inject = Dry::AutoInject(AppContainer)
  end
end
