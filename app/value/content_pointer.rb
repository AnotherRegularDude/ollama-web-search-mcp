# frozen_string_literal: true

# Value object representing a pointer to related content.
#
# This simple value object holds a URL link to related content that
# may be referenced from search results or fetched pages.
#
# @see Entities::RemoteContent for usage in remote content entities
# @see Cases::Formatter::FetchResult for links section formatting
class Value::ContentPointer < AbstractStruct
  # @!attribute [r] link
  #   @return [String] the URL link to related content

  attribute :link, Types::String

  # @example Creating a content pointer
  #   Value::ContentPointer.new(link: "https://example.com/related")
  #
  # @example Using in remote content
  #   Entities::RemoteContent.new(
  #     title: "Example",
  #     url: "https://example.com",
  #     content: "Content...",
  #     related_content: [Value::ContentPointer.new(link: "https://example.com/more")],
  #     source_type: :fetch
  #   )
end
