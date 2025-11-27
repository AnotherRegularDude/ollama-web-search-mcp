# frozen_string_literal: true

# Base class for all service objects in the application.
#
# This class extends Resol::Service to provide a consistent base for all
# service objects in the application. It includes return_in_service plugin
# for consistent result handling and provides error handling for validation.
#
class ServiceObject < Resol::Service
  use_initializer! :dry
  plugin :return_in_service

  class << self
    # Handles constraint errors from Dry::Types and converts them to ArgumentError
    #
    # @return [Object] the result of the parent call method
    # @raise [ArgumentError] if validation constraints are violated
    def call(...)
      super
    rescue Dry::Types::ConstraintError => e
      raise ArgumentError, "Argument[#{e.input.inspect}] is invalid: #{e.result}"
    end
  end
end
