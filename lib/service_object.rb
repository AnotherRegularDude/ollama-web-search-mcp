# frozen_string_literal: true

class ServiceObject < Resol::Service
  use_initializer! :dry
  plugin :return_in_service

  class << self
    def call(...)
      super
    rescue Dry::Types::ConstraintError => e
      raise ArgumentError, "Argument[#{e.input.inspect}] is invalid: #{e.result}"
    end
  end
end
