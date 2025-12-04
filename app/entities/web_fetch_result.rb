# frozen_string_literal: true

# Represents a web fetch result from the Ollama web fetch API.
#
class Entities::WebFetchResult < Dry::Struct
  # @!attribute [r] title
  #   @return [String] the title of the web page

  # @!attribute [r] content
  #   @return [String] the content of the web page

  # @!attribute [r] links
  #   @return [Array<String>] array of links found on the page

  attribute :title, Types::String
  attribute :content, Types::String
  attribute :links, Types::Array.of(Types::String)
end
