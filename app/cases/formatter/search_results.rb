# frozen_string_literal: true

# Formatter for web search results that creates structured output from search result arrays.
#
# This formatter processes arrays of {Entities::RemoteContent} objects representing
# search results and generates formatted output with query information, result count,
# and individual result cards containing titles, URLs, and content snippets.
#
# @example Formatting search results
#   results = [
#     Entities::RemoteContent.new(
#       title: "Ruby Programming Language",
#       url: "https://ruby-lang.org",
#       content: "Ruby is a dynamic, open source programming language...",
#       source_type: :search
#     ),
#     Entities::RemoteContent.new(
#       title: "Ruby Documentation",
#       url: "https://ruby-doc.org",
#       content: "Official Ruby documentation and API reference...",
#       source_type: :search
#     )
#   ]
#
#   formatted = Cases::Formatter::SearchResults.call(
#     results,
#     query: "ruby programming",
#     options: { truncate: false }
#   )
#   puts formatted.value! if formatted.success?
#
# @example Handling empty search results
#   empty_results = []
#   formatted = Cases::Formatter::SearchResults.call(
#     empty_results,
#     query: "nonexistent search term"
#   )
#   puts formatted.value! # Shows "No results found" message
class Cases::Formatter::SearchResults < Cases::Formatter::Base
  # @!attribute [r] results
  #   @return [Array<Entities::RemoteContent>] array of search results to format
  param :results, Types::Array.of(Types.Instance(Entities::RemoteContent))

  # @!attribute [r] query
  #   @return [String] the original search query for context
  option :query, Types::String

  # @!attribute [r] options
  #   @return [Hash] custom formatting options that override defaults
  option :options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  private

  # Builds the formatting schema based on the search results
  #
  # Determines whether to build a schema for results or an empty result
  # based on the presence of search results.
  #
  # @return [Value::RootNode] the root node of the formatting schema
  #
  # @example Building schema for search results
  #   build_schema # => Value::RootNode with header and result nodes
  def build_schema
    if results.empty?
      build_empty_schema
    else
      build_results_schema
    end
  end

  # Builds a schema for empty search results
  #
  # Creates a schema that displays a "No results found" message
  # along with the original query information.
  #
  # @return [Value::RootNode] the root node for empty results schema
  #
  # @example Empty schema structure
  #   build_empty_schema # => RootNode with header section showing query
  def build_empty_schema
    Value::RootNode.new(
      metadata: { query:, total_results: 0 },
      children: [
        Value::Node.new(
          type: :header,
          data: { text: "No results found for query: #{query}" },
        ),
      ],
    )
  end

  # Builds a schema for search results with content
  #
  # Creates a schema containing a header with query information
  # and individual result nodes for each search result.
  #
  # @return [Value::RootNode] the root node for results schema
  #
  # @example Results schema structure
  #   build_results_schema # => RootNode with header and result sections
  def build_results_schema
    Value::RootNode.new(
      metadata: { query:, total_results: results.size },
      children: [
        Value::Node.new(
          type: :header,
          data: { text: "Search Results — \"#{query}\"" },
        ),
        *results.map { |result| build_result_node(result) },
      ],
    )
  end

  # Builds an individual result node for a search result
  #
  # Creates a node containing the result's title, URL, source type,
  # and content snippet.
  #
  # @param result [Entities::RemoteContent] the search result to format
  # @return [Value::Node] a node representing the search result
  #
  # @example Result node structure
  #   build_result_node(result) # => Node(type: :result, data: { title: "...", url: "..." })
  def build_result_node(result)
    Value::Node.new(
      type: :result,
      data: {
        title: result.title,
        url: result.url,
        source: result.source_type,
      },
      children: [
        Value::Node.new(
          type: :content,
          data: { text: result.content },
        ),
      ],
    )
  end
end
