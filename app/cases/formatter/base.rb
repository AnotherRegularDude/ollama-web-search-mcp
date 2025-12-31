# frozen_string_literal: true

class Cases::Formatter::Base < ServiceObject
  DEFAULT_OPTIONS = {
    truncate: true,
    max_chars: 120_000,
  }.freeze

  option :options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  def call
    self.result_schema = build_schema
    process_truncation!

    formatted_output = render_schema!
    success!(formatted_output)
  end

  private

  attr_accessor :result_schema

  def build_schema
    raise NotImplementedError, "#{self.class.name} must implement build_schema"
  end

  def process_truncation!
    return if merged_options[:truncate] == false

    render_result = render_schema!({ ignore_value: true })

    overhead = render_result.size
    content_budget = merged_options[:max_chars] - overhead

    Cases::Node::TruncateContent.call!(result_schema, remaining_length: content_budget)
  end

  def render_schema!(additional_options = {})
    render_service.call(result_schema, additional_options:).value_or do |error|
      fail!(error.code, error.data)
    end
  end

  def render_service
    Cases::Node::RenderMarkdown
  end

  def merged_options
    @merged_options ||= DEFAULT_OPTIONS.merge(options.compact)
  end
end
