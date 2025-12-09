# frozen_string_literal: true

# Formatter for web content fetch results.
#
# This formatter converts a single web fetch result into a structured format
# suitable for presentation to AI assistants, optimized for large content volumes.
# The format supports context compression and hierarchical information presentation.
#
module Formatters
  class WebContentFormatter < BaseFormatter
    # Default maximum content length in characters for preview
    DEFAULT_CONTENT_PREVIEW_LENGTH = 1000

    # Formats web content for presentation
    #
    # @param result [Entities::RemoteContent] the web content to format
    # @param options [Hash] formatting options
    # @option options [Boolean] :include_links whether to include related links (default: true)
    # @option options [Boolean] :compact whether to use compact format (default: false)
    # @option options [Integer] :content_preview_length maximum content length for preview (default: 1000)
    # @option options [Boolean] :include_full_content whether to include full content (default: false)
    # @return [String] formatted web content string
    #
    # @example Format web content in standard format
    #   formatter = Formatters::WebContentFormatter.new
    #   result = Entities::RemoteContent.new(
    #     title: "Example Domain",
    #     url: "https://example.com",
    #     content: "This domain is for use in illustrative examples...",
    #     related_content: [Value::ContentPointer.new(link: "https://example.com/more")]
    #   )
    #   formatter.format(result)
    #
    # @example Format web content in compact format
    #   formatter.format(result, compact: true)
    #
    # @example Format with custom content preview length
    #   formatter.format(result, content_preview_length: 500)
    #
    # @example Format with full content
    #   formatter.format(result, include_full_content: true)
    def format(result, options = {})
      include_links = options.fetch(:include_links, true)
      compact = options.fetch(:compact, false)
      content_preview_length = options.fetch(:content_preview_length, DEFAULT_CONTENT_PREVIEW_LENGTH)
      include_full_content = options.fetch(:include_full_content, false)

      if compact
        build_compact_output(result, include_links)
      else
        build_structured_output(result, include_links, content_preview_length, include_full_content)
      end
    end

    private

    # Builds compact output format for quick overview
    #
    # @param result [Entities::RemoteContent] the fetch result
    # @param include_links [Boolean] whether to include related links
    # @return [String] formatted compact output string
    def build_compact_output(result, include_links)
      StringIO.open do |buffer|
        buffer.puts "=== #{result.title} ==="
        buffer.puts "URL: #{result.url}"

        if content_present?(result.content)
          preview = truncate_content(result.content, 200)
          buffer.puts "Preview: #{preview}..."
        end

        if include_links && result.related_content.any?
          buffer.puts "Links: #{result.related_content.size} related"
        end

        buffer.string.chomp
      end
    end

    # Builds structured output with hierarchical information
    #
    # @param result [Entities::RemoteContent] the fetch result
    # @param include_links [Boolean] whether to include related links
    # @param content_preview_length [Integer] maximum content length for preview
    # @param include_full_content [Boolean] whether to include full content
    # @return [String] formatted structured output string
    def build_structured_output(result, include_links, content_preview_length, include_full_content)
      StringIO.open do |buffer|
        # Metadata section - always visible
        buffer.puts "## #{result.title}"
        buffer.puts "**URL:** #{result.url}"
        buffer.puts "**Source type:** #{result.source_type}"

        # Content section - can be preview or full
        if content_present?(result.content)
          if include_full_content
            buffer.puts "\n### Full Content"
            buffer.puts result.content
          else
            preview = truncate_content(result.content, content_preview_length)
            buffer.puts "\n### Content Preview (#{preview.length} chars)"
            buffer.puts preview
            buffer.puts "\n[... Content truncated. Use `include_full_content: true` to see full content ...]"
          end
        end

        # Links section - structured and compact
        if include_links
          buffer.puts "\n### Links"
          buffer.puts "- **Main URL:** #{result.url}"

          if result.related_content.any?
            buffer.puts "- **Related links (#{result.related_content.size}):**"
            result.related_content.each_slice(3) do |slice|
              links = slice.map { |pointer| "[#{pointer.link}](#{pointer.link})" }.join(" | ")
              buffer.puts "  #{links}"
            end
          end
        end

        buffer.string.chomp
      end
    end

    # Truncates content to specified length with ellipsis
    #
    # @param content [String] the content to truncate
    # @param max_length [Integer] maximum length
    # @return [String] truncated content
    def truncate_content(content, max_length)
      return content unless content.length > max_length

      # Try to truncate at word boundary
      truncated = content[0...max_length]
      last_space = truncated.rindex(' ')

      if last_space && last_space > max_length * 0.8
        truncated[0...last_space] + '...'
      else
        truncated + '...'
      end
    end
  end
end
