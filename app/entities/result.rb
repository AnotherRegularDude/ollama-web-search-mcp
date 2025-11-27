# frozen_string_literal: true

# Represents a search result from the Ollama web search API.
#
class Entities::Result < Dry::Struct
  # @!attribute [r] title
  #   @return [String] the title of the search result

  # @!attribute [r] url
  #   @return [String] the URL of the search result

  # @!attribute [r] content
  #   @return [String] the content/description of the search result

  attribute :title, Types::String
  attribute :url, Types::String
  attribute :content, Types::String
end
