# frozen_string_literal: true

# Formatter for web search results.
#
# This formatter converts an array of search results into a formatted string
# suitable for presentation to AI assistants.
#
class Formatters::SearchResultsFormatter < Formatters::BaseFormatter
  # Formats search results for presentation
  #
  # @param results [Array<Entities::RemoteContent>] the search results to format
  # @param options [Hash] formatting options
  # @option options [String] :query the original search query
  # @option options [Integer] :max_results maximum number of results to include
  # @return [String] formatted search results string
  #
  # @example Format search results
  #   formatter = Formatters::SearchResultsFormatter.new
  #   results = [Entities::RemoteContent.new(...), ...]
  #   formatter.format(results, query: "ruby programming")
  #   # => "Search results for: ruby programming\n\n1. Ruby\n  URL: https://ruby-lang.org\n  Content: ..."
  def format(results, options = {})
    query = options[:query]
    max_results = options[:max_results] || results.size

    return "No results found for query: #{query}" if results.empty?

    build_results_output(results.first(max_results), query)
  end

  private

  # Builds the complete output string for all results
  #
  # @param results [Array<Entities::RemoteContent>] the search results
  # @param query [String] the original search query
  # @return [String] formatted output string
  def build_results_output(results, query)
    output = "Search results for: #{query}\n\n"

    results.each_with_index do |result, index|
      output << format_result(index + 1, result)
    end

    output.chomp
  end

  # Formats a single search result
  #
  # @param number [Integer] the result number (1-based)
  # @param result [Entities::RemoteContent] the search result to format
  # @return [String] formatted result string
  def format_result(number, result)
    <<~RESULT
      #{number}. #{result.title}
        URL: #{result.url}
        Content: #{result.content}
    RESULT
  end
end
