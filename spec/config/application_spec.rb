# frozen_string_literal: true

describe Application do
  describe ".fetch_api_key" do
    before { stub_const("Application::ENV", env_stub) }
    after { described_class.instance_variable_set(:@fetch_api_key, nil) }

    let(:env_stub) { { "OLLAMA_API_KEY" => ollama_api_key } }
    let(:ollama_api_key) { "test key" }

    it "resolves api key from env" do
      expect(described_class.fetch_api_key).to eq("test key")
    end

    context "without key in env" do
      let(:env_stub) { {} }

      it "raises an error" do
        expect { described_class.fetch_api_key }.to raise_error(KeyError)
      end
    end
  end
end
