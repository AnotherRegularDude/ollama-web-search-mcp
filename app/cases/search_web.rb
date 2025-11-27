# frozen_string_literal: true

class Cases::SearchWeb < ServiceObject
  param :query, Types::String
  option :max_results, Types::Integer.constrained(included_in: 1...10), optional: true

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
  rescue Adapters::OllamaGateway::HTTPError => e
    fail!(:request_failed, { message: e.message })
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
