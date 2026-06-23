# frozen_string_literal: true

require 'erb'

require_relative 'initializers/environment'
require_relative 'docs/swagger_docs'
require_relative 'routes/api/v1/rooms_routes'
require_relative 'routes/api/v1/auth_routes'

module App
  class Server < Hanami::API
    get '/api-docs/swagger.json' do
      App::Docs::SwaggerDocs.generate_docs
    end

    get '/docs' do
      redirect '/api-docs/'
    end

    get '/api-docs' do
      redirect '/api-docs/'
    end

    get '/api-docs/' do
      headers['Content-Type'] = 'text/html'
      path = File.expand_path('index.html.erb', './src/app/docs')
      ERB.new(File.read(path)).result(binding)
    end

    App::Routes::API::V1::AuthRoutes.register(self)
    App::Routes::API::V1::RoomsRoutes.register(self)
  end
end
