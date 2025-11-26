# frozen_string_literal: true

class Cases::SearchWeb < Cases::Abstract
  param :query, Types::Integer
  option :max_results, Types::Integer.nilable

  def call
  end
end
