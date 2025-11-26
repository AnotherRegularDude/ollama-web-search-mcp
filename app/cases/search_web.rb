# frozen_string_literal: true

class Cases::SearchWeb < Cases::Abstract
  param :query, Types::String
  option :max_results, Types::Integer, optional: true

  def call
    self.results = search!
    map_results!

    success!(results)
  end

  private

  attr_accessor :results

  def search!
    Adapters::OllamaGateway.process_web_search!(
      query: query,
      max_results: max_results || Application.max_results_by_default,
    )
  end

  def map_results!
    results.map! do |result|
      Entities::Result.new(
        title: result["title"],
        url: result["url"],
        content: result["content"],
      )
    end
  end
end
