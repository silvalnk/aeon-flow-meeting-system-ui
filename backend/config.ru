# frozen_string_literal: true

require 'bundler/setup'
require 'debug'
require 'hanami/api'
require 'hanami/middleware/body_parser'

require_relative 'src/app/initializers/environment'
require_relative 'src/app/server'
require_relative 'src/app/interceptors/cors'
require_relative 'src/app/interceptors/content_type'
require_relative 'src/app/interceptors/accept'
require_relative 'src/app/interceptors/error_handler'
require_relative 'src/app/interceptors/auth'

use App::Interceptors::ErrorHandler
use App::Interceptors::Auth
use App::Interceptors::Cors
use App::Interceptors::Accept
use App::Interceptors::ContentType
use Hanami::Middleware::BodyParser, [:json]

run App::Server.new

