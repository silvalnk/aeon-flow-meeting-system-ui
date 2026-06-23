# frozen_string_literal: true

require_relative 'errors/invalid_transaction_error'

module SharedDomain
  module Infrastructure
    class UnitOfWork
      def initialize(rom)
        @rom = rom
      end

      def transaction(relation_name = nil, &block)
        gateway = relation_name ? @rom[relation_name] : @rom.container.gateways[:default]
        gateway.transaction do |t|
          yield t if block_given?
        rescue StandardError => e
          t.rollback!
          raise e
        end
      end
    end
  end
end
