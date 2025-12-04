# frozen_string_literal: true

shared_context "ollama request context" do
  def read_data
    File.read(__FILE__).scan(/\n__END__\n(.*)/m).flatten.first
  end

  before { stub_const("Application::ENV", stub_env) }
  before do
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
  { "results": [{ "title": "Title one", "url": "https://example.com/1", "content": "Content one" }] }
fetch_response: |
  { "title": "Example Page", "content": "This is the content of the page.", "links": ["https://example.com", "https://example.com/about"] }
