# frozen_string_literal: true

# Formatter for web fetch results that creates structured output from remote content.
#
# This formatter processes {Entities::RemoteContent} objects and generates
# formatted output with metadata, content, and related links sections.
# It handles both successful fetches with content and empty responses gracefully.
#
# @example Formatting a successful web fetch result
#   content = Entities::RemoteContent.new(
#     title: "Example Page",
#     url: "https://example.com",
#     content: "This is the page content...",
#     related_content: [Value::ContentPointer.new(link: "https://example.com/related")],
#     source_type: :fetch
#   )
#
#   result = Cases::Formatter::FetchResult.call(content)
#   if result.success?
#     puts result.value!
#   end
#
# @example Handling an empty fetch result
#   empty_content = Entities::RemoteContent.new(
#     title: "Empty Page",
#     url: "https://empty.example.com",
#     content: "",
#     source_type: :fetch
#   )
#
#   result = Cases::Formatter::FetchResult.call(empty_content)
#   puts result.value! # Shows "No content found" message
class Cases::Formatter::FetchResult < Cases::Formatter::Base
  # @!attribute [r] result
  #   @return [Entities::RemoteContent] the web fetch result to format
  param :result, Types::Instance(Entities::RemoteContent)

  private

  # Builds the formatting schema based on the fetch result content
  #
  # Determines whether to build a schema for content or an empty result
  # based on the presence of content and related links.
  #
  # @return [Value::RootNode] the root node of the formatting schema
  #
  # @example Building schema for content with links
  #   build_schema # => Value::RootNode with metadata, content, and links sections
  def build_schema
    if content_empty? && !links_present?
      build_empty_schema
    else
      build_content_schema
    end
  end

  # Checks if the result has related content links
  #
  # @return [Boolean] true if there are related content links present
  #
  # @example Checking for links
  #   links_present? # => true if result.related_content.any?
  def links_present?
    result.related_content.any?
  end

  # Checks if the result has empty content
  #
  # @return [Boolean] true if the content is empty or contains only whitespace
  #
  # @example Checking for empty content
  #   content_empty? # => true if result.content.to_s.strip.empty?
  def content_empty?
    result.content.to_s.strip.empty?
  end

  # Builds a schema for empty fetch results
  #
  # Creates a schema that displays a "No content found" message
  # along with metadata about the source URL.
  #
  # @return [Value::RootNode] the root node for empty content schema
  #
  # @example Empty schema structure
  #   build_empty_schema # => RootNode with metadata and header sections
  def build_empty_schema
    Value::RootNode.new(
      metadata: { url: result.url, source: result.source_type },
      children: [
        Value::Node.new(
          type: :metadata,
          data: { source: result.source_type, url: result.url },
        ),
        Value::Node.new(
          type: :header,
          data: { text: "No content found for URL: #{result.url}" },
        ),
      ],
    )
  end

  # Builds a schema for fetch results with content
  #
  # Creates a schema containing metadata, content, and links sections
  # based on what's available in the result.
  #
  # @return [Value::RootNode] the root node for content schema
  #
  # @example Content schema structure
  #   build_content_schema # => RootNode with appropriate sections
  def build_content_schema
    children = []

    children << build_metadata_node
    children << build_content_node if content_present?
    children << build_links_node if links_present?

    Value::RootNode.new(
      metadata: { url: result.url, source: result.source_type },
      children:,
    )
  end

  # Builds the metadata node for the schema
  #
  # @return [Value::Node] a node containing source and URL information
  #
  # @example Metadata node structure
  #   build_metadata_node # => Node(type: :metadata, data: { source: :fetch, url: "..." })
  def build_metadata_node
    Value::Node.new(
      type: :metadata,
      data: { source: result.source_type, url: result.url },
    )
  end

  # Checks if content is present in the result
  #
  # @return [Boolean] true if content is present (opposite of {#content_empty?})
  #
  # @example Checking content presence
  #   content_present? # => !content_empty?
  def content_present?
    !content_empty?
  end

  # Builds the content node for the schema
  #
  # @return [Value::Node] a node containing the main content text
  #
  # @example Content node structure
  #   build_content_node # => Node(type: :content, data: { text: "content text..." })
  def build_content_node
    Value::Node.new(
      type: :content,
      data: { text: result.content.dup },
    )
  end

  # Builds the links node for the schema
  #
  # @return [Value::Node] a node containing related content links
  #
  # @example Links node structure
  #   build_links_node # => Node(type: :links, data: { links: ["url1", "url2"] })
  def build_links_node
    Value::Node.new(
      type: :links,
      data: { links: result.related_content.map(&:link) },
    )
  end
end
