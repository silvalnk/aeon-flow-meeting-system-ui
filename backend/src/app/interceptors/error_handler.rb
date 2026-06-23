# frozen_string_literal: true

module App
  module Interceptors
    class ErrorHandler
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Hanami::Middleware::BodyParser::BodyParsingError
        error_response(400, message: 'Invalid JSON format')
      rescue StandardError => e
        warn "[ErrorHandler] #{e.class}: #{e.message}" if ENV['ENVIRONMENT'] == 'development'
        error_response(500, message: 'Something went wrong')
      end

      private

      def error_response(status, body)
        headers = {
          'Content-Type' => 'application/json',
          'access-control-allow-origin' => '*',
          'access-control-allow-headers' => '*',
          'access-control-allow-methods' => '*'
        }
        [status, headers, [body.to_json]]
      end
    end
  end
end
