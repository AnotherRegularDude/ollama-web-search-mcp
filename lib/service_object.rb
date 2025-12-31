# frozen_string_literal: true

# Base class for all service objects in the application.
#
# This class extends Resol::Service to provide a consistent base for all
# service objects in the application. It includes return_in_service plugin
# for consistent result handling and provides error handling for validation.
#
# Service objects can be called in two ways:
# 1. Using `call` which returns a result monad (Success or Failure)
# 2. Using `call!` which automatically unwraps the value or raises an exception on failure
#
class ServiceObject < Resol::Service
  use_initializer! :dry
  plugin :return_in_service

  class << self
    # Handles constraint errors from Dry::Types and converts them to ArgumentError
    #
    # @return [Object] the result of the parent call method
    # @raise [ArgumentError] if validation constraints are violated
    #
    # @example Calling a service with invalid parameters
    #   # This would raise ArgumentError if max_results is outside 1..10
    #   Cases::SearchWeb.call("query", max_results: 15)
    #
    # @example Using call! which will raise the service failure as an exception
    #   # This would raise the service's Failure error if the service fails
    #   Cases::SearchWeb.call!("query")
    def call(...)
      super
    rescue Dry::Types::ConstraintError => e
      raise ArgumentError, "Argument[#{e.input.inspect}] is invalid: #{e.result}"
    end
  end
end
