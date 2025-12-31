# frozen_string_literal: true

# Type definitions for the application.
#
# This module includes Dry::Types to provide a consistent set of type
# definitions used throughout the application for validation and structure.
#
module Types
  include Dry.Types

  EMPTY_HASH = {}.freeze
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
