# frozen_string_literal: true

# Represents a web fetch result from the Ollama web fetch API.
#
# This entity contains the structured data for a web page fetch result,
# including the title, content, and links found on the page.
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

  # @example Creating a new web fetch result
  #   result = Entities::WebFetchResult.new(
  #     title: "Example Domain",
  #     content: "This domain is for use in illustrative examples...",
  #     links: ["https://example.com/more"]
  #   )
end
