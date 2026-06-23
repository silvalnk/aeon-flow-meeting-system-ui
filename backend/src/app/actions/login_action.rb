# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/auth/application/use_cases/login_use_case'

module App
  module Actions
    class LoginAction < SharedDomain::Web::Action
      def call(params = {})
        Auth::Application::UseCases::LoginUseCase.new.call(
          email: params[:email],
          password: params[:password]
        ) do |m|
          m.success do |data|
            { status: 200, body: data }
          end
          m.failure do |failure|
            case failure[:status]
            when :unauthorized then { status: 401, body: { error: failure[:message] } }
            else { status: 500, body: { error: failure[:message] } }
            end
          end
        end
      end
    end
  end
end
