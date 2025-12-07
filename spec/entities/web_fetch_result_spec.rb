# frozen_string_literal: true

describe Entities::WebFetchResult do
  let(:title) { "Example Page" }
  let(:url) { "https://example.com" }
  let(:content) { "This is the content of the page." }
  let(:links) { ["https://example.com", "https://example.com/about"] }

  subject { described_class.new(title: title, url: url, content: content, links: links) }

  it "creates an instance with the correct attributes" do
    expect(subject.title).to eq(title)
    expect(subject.url).to eq(url)
    expect(subject.content).to eq(content)
    expect(subject.links).to eq(links)
  end

  it "is a Dry::Struct" do
    expect(subject).to be_a(Dry::Struct)
  end

  context "with invalid data" do
    it "raises an error when title is not a string" do
      expect { described_class.new(title: 123, url: url, content: content, links: links) }
        .to raise_error(Dry::Struct::Error)
    end

    it "raises an error when url is not a string" do
      expect { described_class.new(title: title, url: 123, content: content, links: links) }
        .to raise_error(Dry::Struct::Error)
    end

    it "raises an error when content is not a string" do
      expect { described_class.new(title: title, url: url, content: 123, links: links) }
        .to raise_error(Dry::Struct::Error)
    end

    it "raises an error when links is not an array of strings" do
      expect { described_class.new(title: title, url: url, content: content, links: [123]) }
        .to raise_error(Dry::Struct::Error)
    end
  end
end
