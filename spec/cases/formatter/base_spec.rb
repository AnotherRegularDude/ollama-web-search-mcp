# frozen_string_literal: true

describe Cases::Formatter::Base do
  subject(:service) { Class.new(Cases::Formatter::Base) }

  let(:options) { {} }

  it "raises NotImplementedError" do
    expect { service.call(options: {}) }.to raise_error(NotImplementedError, " must implement build_schema")
  end
end
