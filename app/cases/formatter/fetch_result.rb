# frozen_string_literal: true

class Cases::Formatter::FetchResult < Cases::Formatter::Base
  param :result, Types::Instance(Entities::RemoteContent)

  private

  def build_schema
    if content_empty? && !links_present?
      build_empty_schema
    else
      build_content_schema
    end
  end

  def links_present?
    result.related_content.any?
  end

  def content_empty?
    result.content.to_s.strip.empty?
  end

  def build_empty_schema
    Value::RootNode.new(
      metadata: { url: result.url, source: result.source_type },
      children: [
        Value::Node.new(
          type: :metadata,
          data: { source: result.source_type, url: result.url },
        ),
        Value::Node.new(
          type: :header,
          data: { text: "No content found for URL: #{result.url}" },
        ),
      ],
    )
  end

  def build_content_schema
    children = []

    children << build_metadata_node
    children << build_content_node if content_present?
    children << build_links_node if links_present?

    Value::RootNode.new(
      metadata: { url: result.url, source: result.source_type },
      children:,
    )
  end

  def build_metadata_node
    Value::Node.new(
      type: :metadata,
      data: { source: result.source_type, url: result.url },
    )
  end

  def content_present?
    !content_empty?
  end

  def build_content_node
    Value::Node.new(
      type: :content,
      data: { text: result.content },
    )
  end

  def build_links_node
    Value::Node.new(
      type: :links,
      data: { links: result.related_content.map(&:link) },
    )
  end
end
