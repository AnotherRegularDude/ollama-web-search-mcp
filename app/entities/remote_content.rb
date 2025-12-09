# frozen_string_literal: true

class Entities::RemoteContent < AbstractStruct
  # @!attribute [r] title
  #   @return [String] the title of the content

  # @!attribute [r] url
  #   @return [String] the URL of the content

  # @!attribute [r] content
  #   @return [String] the main content of the remote resource

  # @!attribute [r] related_content
  #   @return [Array<Value::ContentPointer>] array of related content pointers

  # @!attribute [r] source_type
  #   @return [Symbol] the type of source (:search, :fetch, etc.)

  attribute :title, Types::String
  attribute :url, Types::String
  attribute :content, Types::String
  attribute :related_content, Types::Array.of(Value::ContentPointer).default([].freeze)
  attribute :source_type, Types::Symbol.default(:unknown)

  # @example Creating a search result
  #   Entities::RemoteContent.new(
  #     title: "Ruby Programming",
  #     url: "https://ruby-lang.org",
  #     content: "Ruby is a dynamic programming language...",
  #     source_type: :search
  #   )

  # @example Creating a fetched page
  #   Entities::RemoteContent.new(
  #     title: "Example Domain",
  #     url: "https://example.com",
  #     content: "This domain is for use in illustrative examples...",
  #     related_content: [Value::ContentPointer.new(link: "https://example.com/more")],
  #     source_type: :fetch
  #   )
end
