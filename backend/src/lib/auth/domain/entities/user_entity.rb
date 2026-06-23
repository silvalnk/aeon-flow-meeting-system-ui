# frozen_string_literal: true

require 'bcrypt'

require_relative '../../../shared_domain/domain/entity'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'

module Auth
  module Domain
    module Entities
      class User < SharedDomain::Domain::Entity
        attribute :email, SharedDomain::Domain::Types::Strict::String
        attribute :password_digest, SharedDomain::Domain::Types::Strict::String
        attribute :name, SharedDomain::Domain::Types::Strict::String

        def initialize(attributes)
          attributes[:id] = if attributes[:id].is_a?(String)
                              SharedDomain::Domain::ValueObjects::UuidValueObject.new(value: attributes[:id])
                            else
                              SharedDomain::Domain::ValueObjects::UuidValueObject.new
                            end
          super
        end

        def authenticate(password)
          BCrypt::Password.new(password_digest) == password
        end
      end
    end
  end
end
