# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'
require_relative '../../infrastructure/services/jwt_token_service'

module Auth
  module Application
    module UseCases
      class LoginUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @user_repository = Auth::AppContainer.resolve('auth.infrastructure.user_repository')
          super
        end

        def call(input_dto = {})
          user = @user_repository.find_by_email(input_dto[:email])
          return Failure(status: :unauthorized, message: 'Invalid credentials') unless user
          return Failure(status: :unauthorized, message: 'Invalid credentials') unless user.authenticate(input_dto[:password])

          token = ::Auth::Infrastructure::Services::JwtTokenService.encode(user.id.value, user.email)
          Success(token: token, user: { id: user.id.value, email: user.email, name: user.name })
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
