# frozen_string_literal: true

# Base class for all entity structures in the application.
#
# This class extends Dry::Struct to provide a consistent base for all
# entity objects in the application, ensuring type safety and immutability.
#
class AbstractStruct < Dry::Struct
end
