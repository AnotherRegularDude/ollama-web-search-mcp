# frozen_string_literal: true

# Base class for all response formatters.
#
# This class defines the interface for formatters that convert
# search and fetch results into formatted strings for AI assistants.
#
class Formatters::BaseFormatter
  # Formats the given data for presentation
  #
  # @param data [Object] the data to format (type depends on formatter)
  # @param options [Hash] additional formatting options
  # @return [String] formatted output string
  # @raise [NotImplementedError] if not implemented by subclass
  def format(data, options = {})
    raise NotImplementedError, "#{self.class} must implement #format method"
  end

  private

  # Helper method to check if content is present and non-empty
  #
  # @param content [String] the content to check
  # @return [Boolean] true if content is present and non-empty
  def content_present?(content)
    content.is_a?(String) && !content.strip.empty?
  end
end
