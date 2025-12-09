# frozen_string_literal: true

require "spec_helper"

RSpec.describe Formatters::SearchResultsFormatter do
  subject(:formatter) { described_class.new }

  let(:remote_content_class) { Entities::RemoteContent }

  describe "#format" do
    context "with empty results" do
      it "returns a no results message" do
        result = formatter.format([], query: "test query")
        expect(result).to eq("No results found for query: test query")
      end
    end

    context "with results" do
      let(:results) do
        [
          remote_content_class.new(
            title: "Ruby Programming",
            url: "https://ruby-lang.org",
            content: "Ruby is a dynamic programming language",
            source_type: :search,
          ),
          remote_content_class.new(
            title: "Ruby on Rails",
            url: "https://rubyonrails.org",
            content: "Rails is a web framework for Ruby",
            source_type: :search,
          ),
        ]
      end

      it "formats search results with query" do
        result = formatter.format(results, query: "ruby programming")
        expected = <<~OUTPUT.chomp
          Search results for: ruby programming

          1. Ruby Programming
            URL: https://ruby-lang.org
            Content: Ruby is a dynamic programming language
          2. Ruby on Rails
            URL: https://rubyonrails.org
            Content: Rails is a web framework for Ruby
        OUTPUT

        expect(result).to eq(expected)
      end

      it "respects max_results option" do
        result = formatter.format(results, query: "ruby", max_results: 1)
        expected = <<~OUTPUT.chomp
          Search results for: ruby

          1. Ruby Programming
            URL: https://ruby-lang.org
            Content: Ruby is a dynamic programming language
        OUTPUT

        expect(result).to eq(expected)
      end
    end
  end
end
