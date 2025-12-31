# frozen_string_literal: true

# Service object for fetching web content using the Ollama web fetch API.
#
# This service processes web fetch requests and returns structured results.
# It handles the communication with the Ollama gateway and maps the raw API
# responses to typed entities.
#
class Cases::WebFetch < ServiceObject
  # @!attribute [r] url
  #   @return [String] the URL to fetch

  param :url, Types::String

  # Executes the web fetch and returns the results
  #
  # @return [Resol::Service::Value] a service result containing a {Entities::RemoteContent} object
  # @raise [ArgumentError] if the parameters are invalid
  # @raise [self::Failure] if using `call!` and the service fails
  #
  # @example Basic usage with result monad
  #   result = Cases::WebFetch.call("https://example.com")
  #   if result.success?
  #     fetch_result = result.value!
  #     puts fetch_result.title
  #     puts fetch_result.content
  #     puts fetch_result.links
  #   end
  #
  # @example Using call! to automatically unwrap the result
  #   fetch_result = Cases::WebFetch.call!("https://example.com")
  #   puts fetch_result.title
  #   puts fetch_result.content
  #   puts fetch_result.links
  #
  # @example Handling fetch errors
  #   result = Cases::WebFetch.call("https://nonexistent.com")
  #   if result.failure?
  #     puts "Failed to fetch: #{result.error[:message]}"
  #   end
  def call
    self.result = fetch!
    map_result!

    success!(result)
  end

  private

  # @!attribute [rw] result
  #   @return [Hash] raw fetch result from the API
  # @api private

  attr_accessor :result

  # Performs the actual fetch using the Ollama gateway
  #
  # @return [Hash] raw fetch result from the API containing title, content, and links
  # @raise [Adapters::OllamaGateway::HTTPError] if the HTTP request fails
  #
  # @example Fetch content from a URL
  #   fetch!
  #   # => {"title"=>"Example Domain", "content"=>"...", "links"=>["https://example.com/more"]}
  # @api private
  def fetch!
    Adapters::OllamaGateway.process_web_fetch!(url:)
  rescue Adapters::OllamaGateway::HTTPError => e
    fail!(:request_failed, { message: e.message })
  end

  # Maps raw API result to typed entity
  #
  # @return [void]
  #
  # @example Map raw result to entity
  #   result = {"title"=>"Example", "content"=>"...", "links"=>["https://example.com/more"]}
  #   map_result!
  #   # result is now an Entities::RemoteContent object
  # @api private
  def map_result!
    self.result = Entities::RemoteContent.new(
      title: result["title"],
      url:,
      content: result["content"],
      related_content: result["related_content"].map { |link_data| Value::ContentPointer.new(link: link_data["url"]) },
      source_type: :fetch,
    )
  end
end
