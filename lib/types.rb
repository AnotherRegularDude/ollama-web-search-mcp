# frozen_string_literal: true

# Type definitions for the application.
#
# This module includes Dry::Types to provide a consistent set of type
# definitions used throughout the application for validation and structure.
#
# @see Dry::Types for base type system
# @see AbstractStruct for type-safe data structures
module Types
  include Dry.Types

  # Empty hash constant for default values and initialization
  #
  # This frozen empty hash is used throughout the application
  # as a safe default value for hash parameters and options.
  #
  # @return [Hash] an empty frozen hash
  #
  # @example Using as default value
  #   option :options, Types::Hash, default: Types::EMPTY_HASH
  EMPTY_HASH = {}.freeze

  # Default proc that returns an empty hash
  #
  # This proc is used when a dynamic default value is needed
  # that returns a new empty hash instance on each call.
  #
  # @return [Proc] a proc that returns an empty hash
  #
  # @example Using as default proc
  #   option :options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT
  EMPTY_HASH_DEFAULT = proc { EMPTY_HASH }

  # @example Using string type
  #   Types::String
  #
  # @example Using integer type with constraints
  #   Types::Integer.constrained(included_in: 1..10)
  #
  # @example Using array of strings
  #   Types::Array.of(Types::String)
end
