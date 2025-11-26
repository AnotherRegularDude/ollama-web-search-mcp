# frozen_string_literal: true

class Entities::Result < Dry::Struct
  attribute :title, Types::String
  attribute :url, Types::String
  attribute :content, Types::String
end
