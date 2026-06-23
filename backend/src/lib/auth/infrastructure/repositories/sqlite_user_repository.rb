# frozen_string_literal: true

require_relative '../../app_container'
require_relative '../../application/repositories/user_repository'
require_relative '../../domain/entities/user_entity'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'

module Auth
  module Infrastructure
    module Repositories
      class SqliteUserRepository < Auth::Application::Repositories::UserRepository
        def initialize
          @rom = Auth::AppContainer.resolve('infrastructure.rom')
          super
        end

        def find_by_email(email)
          row = @rom[:users].where(email: email).one
          return nil unless row

          to_entity(row)
        end

        def add(entity)
          @rom[:users].command(:create).call(
            id: entity.id.value,
            email: entity.email,
            password_digest: entity.password_digest,
            name: entity.name
          )
        end

        private

        def to_entity(dao)
          Domain::Entities::User.new(
            id: dao[:id],
            email: dao[:email],
            password_digest: dao[:password_digest],
            name: dao[:name]
          )
        end
      end
    end
  end
end
