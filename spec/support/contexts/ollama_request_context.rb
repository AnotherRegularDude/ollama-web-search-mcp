# frozen_string_literal: true

# Shared context for stubbing Ollama API requests in tests
# Provides standardized request/response handling for both web_search and web_fetch operations
shared_context "ollama request context" do
  def read_data
    File.read(__FILE__).scan(/\n__END__\n(.*)/m).flatten.first
  end

  before do
    stub_const("Application::ENV", stub_env)
    Application.instance_variable_set(:@fetch_api_key, nil)
    Adapters::OllamaGateway.instance_variables.each { Adapters::OllamaGateway.instance_variable_set(it, nil) }
  end

  before do
    stub_request(:post, request_url).to_return do |request|
      requests << request
      {
        status: response_status,
        body: response_body,
        headers: { "Content-Type" => "application/json" },
      }
    end
  end

  after do
    Application.instance_variable_set(:@fetch_api_key, nil)
    Adapters::OllamaGateway.instance_variables.each { Adapters::OllamaGateway.instance_variable_set(it, nil) }
  end

  let(:data) { YAML.load(ERB.new(read_data).result(binding), symbolize_names: true) }

  let(:requests) { [] }

  let(:stub_env) { Hash["OLLAMA_API_KEY" => api_key] }
  let(:api_key) { "test key" }

  let(:request_url) { File.join("https://ollama.com/api", web_action) }

  let(:response_status) { 200 }
end

__END__

search_response: |
  {
    "results": [
      {
        "title": "Example Search Result 1",
        "url": "https://example.com/result1",
        "content": "This is the content of the first search result.",
        "related_content": [
          {
            "title": "Related Link 1",
            "url": "https://example.com/related1"
          }
        ]
      },
      {
        "title": "Example Search Result 2",
        "url": "https://example.com/result2",
        "content": "This is the content of the second search result.",
        "related_content": [
          {
            "title": "Related Link 2",
            "url": "https://example.com/related2"
          }
        ]
      }
    ]
  }

fetch_response: |
  {
    "title": "Example Web Page",
    "url": "https://example.com",
    "content": "This is the main content of the fetched web page.",
    "links": ["https://example.com", "https://example.com/about"]
  }
