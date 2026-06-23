# frozen_string_literal: true

require_relative '../../lib/auth/infrastructure/services/jwt_token_service'

module App
  module Interceptors
    class Auth
      PUBLIC_PATHS = [
        %r{^/api/v1/auth/login$},
        %r{^/api-docs},
        %r{^/docs},
        %r{^/api/v1/rooms$}
      ].freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) if env['REQUEST_METHOD'] == 'OPTIONS'

        request_path = env['PATH_INFO']
        request_method = env['REQUEST_METHOD']

        return @app.call(env) if public_path?(request_path, request_method)

        auth_header = env['HTTP_AUTHORIZATION']
        return unauthorized unless auth_header&.start_with?('Bearer ')

        token = auth_header.split(' ', 2).last
        payload = ::Auth::Infrastructure::Services::JwtTokenService.decode(token)
        return unauthorized unless payload

        env['current_user'] = payload
        @app.call(env)
      end

      private

      def public_path?(path, method)
        return true if method == 'GET' && path == '/api/v1/reservations'
        return true if method == 'GET' && path.match?(%r{^/api/v1/rooms(/[^/]+)?$})
        return true if method == 'GET' && path.match?(%r{^/api/v1/rooms/[^/]+/reservations(/[^/]+)?$})

        PUBLIC_PATHS.any? { |pattern| path.match?(pattern) }
      end

      def unauthorized
        [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
      end
    end
  end
end
