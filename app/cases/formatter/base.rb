# frozen_string_literal: true

# Base class for formatters that process and format remote content.
#
# This abstract class provides common functionality for formatting search results
# and web content, including content truncation and markdown rendering.
# Subclasses must implement the {#build_schema} method to define their specific
# formatting structure.
#
# @example Using a custom formatter
#   class MyFormatter < Cases::Formatter::Base
#     private
#
#     def build_schema
#       { header: "Custom Results", items: @input_data }
#     end
#   end
#
#   formatter = MyFormatter.call(data, options: { truncate: false })
#   if formatter.success?
#     puts formatter.value!
#   end
class Cases::Formatter::Base < ServiceObject
  # Default formatting options for content processing
  #
  # @!attribute [r] truncate
  #   @return [Boolean] whether to truncate content to fit within character limits (default: true)
  # @!attribute [r] max_chars
  #   @return [Integer] maximum character limit for formatted output (default: 120,000)
  DEFAULT_OPTIONS = {
    truncate: true,
    max_chars: 120_000,
  }.freeze

  # @!attribute [r] options
  #   @return [Hash] custom formatting options that override defaults
  option :options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  # Processes and formats content according to the specified options
  #
  # This method orchestrates the formatting pipeline:
  # 1. Builds the formatting schema using {#build_schema}
  # 2. Processes content truncation if enabled
  # 3. Renders the final formatted output
  #
  # @return [Resol::Service::Value] a service result containing the formatted string output
  # @raise [ArgumentError] if the parameters are invalid
  # @raise [self::Failure] if using `call!` and the service fails
  #
  # @example Basic usage
  #   result = Cases::Formatter::Base.call(input_data, options: { truncate: false })
  #   if result.success?
  #     formatted_output = result.value!
  #     puts formatted_output
  #   end
  #
  # @example Using call! for automatic unwrapping
  #   formatted_output = Cases::Formatter::Base.call!(input_data)
  #   puts formatted_output
  def call
    self.result_schema = build_schema
    process_truncation!

    formatted_output = render_schema!
    success!(formatted_output)
  end

  private

  # @!attribute [rw] result_schema
  #   @return [Hash] the internal schema structure used for formatting
  attr_accessor :result_schema

  # Builds the formatting schema structure
  #
  # This abstract method must be implemented by subclasses to define
  # the specific formatting structure for their content type.
  #
  # @return [Hash] a schema structure that will be processed and rendered
  # @raise [NotImplementedError] if the subclass doesn't implement this method
  #
  # @example Implementation in a subclass
  #   def build_schema
  #     {
  #       title: @input_data[:title],
  #       content: @input_data[:content],
  #       links: @input_data[:related_links]
  #     }
  #   end
  def build_schema
    raise NotImplementedError, "#{self.class.name} must implement build_schema"
  end

  # Processes content truncation based on formatting options
  #
  # This method calculates the available content budget after accounting
  # for formatting overhead and applies truncation to the result schema
  # if truncation is enabled.
  #
  # @return [void]
  #
  # @example Truncation calculation
  #   # If max_chars is 1000 and formatting overhead is 200,
  #   # available content budget is 800 characters
  #   process_truncation!
  def process_truncation!
    return if merged_options[:truncate] == false

    render_result = render_schema!({ ignore_value: true })

    overhead = render_result.size
    content_budget = merged_options[:max_chars] - overhead

    Cases::Node::TruncateContent.call!(result_schema, remaining_length: content_budget)
  end

  # Renders the schema structure to formatted output
  #
  # @param additional_options [Hash] additional options to pass to the render service
  # @return [String] the rendered formatted output
  # @raise [self::Failure] if rendering fails
  #
  # @example Rendering with additional options
  #   render_schema!({ theme: :compact })
  def render_schema!(additional_options = {})
    render_service.call(result_schema, additional_options:).value_or do |error|
      fail!(error.code, error.data)
    end
  end

  # Returns the render service class to use for formatting
  #
  # @return [Class] the render service class (default: Cases::Node::RenderMarkdown)
  #
  # @example Overriding in a subclass
  #   def render_service
  #     Cases::Node::RenderHTML
  #   end
  def render_service
    Cases::Node::RenderMarkdown
  end

  # Merges default options with custom options
  #
  # @return [Hash] the merged options hash with defaults applied
  #
  # @example Merging options
  #   merged_options # => { truncate: true, max_chars: 120000, custom_option: "value" }
  def merged_options
    @merged_options ||= DEFAULT_OPTIONS.merge(options.compact)
  end
end
