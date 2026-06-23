# frozen_string_literal: true

require 'dry-auto_inject'

require_relative '../shared_domain/container'
require_relative 'infrastructure/repositories/sqlite_user_repository'
require_relative 'infrastructure/services/jwt_token_service'

module Auth
  class AppContainer < SharedDomain::Container
    namespace :auth do
      namespace :infrastructure do
        register(:user_repository) { Auth::Infrastructure::Repositories::SqliteUserRepository.new }
        register(:jwt_token_service) { Auth::Infrastructure::Services::JwtTokenService }
      end
    end

    Inject = Dry::AutoInject(AppContainer)
  end
end
