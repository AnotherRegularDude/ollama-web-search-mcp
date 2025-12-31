# frozen_string_literal: true

class Cases::Formatter::SearchResults < Cases::Formatter::Base
  param :results, Types::Array.of(Types.Instance(Entities::RemoteContent))
  option :query, Types::String
  option :options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  private

  def build_schema
    if results.empty?
      build_empty_schema
    else
      build_results_schema
    end
  end

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
