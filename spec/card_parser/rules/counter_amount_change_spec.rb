# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::CounterAmountChange do
  let(:doubler) { "If you would put one or more counters on a permanent or player, put twice that many of each of those kinds of counters on that permanent or player instead." }
  let(:halver) { "If an opponent would put one or more counters on a permanent or player, they put half that many of each of those kinds of counters on that permanent or player instead, rounded down." }

  it "parses both wordings" do
    expect(described_class.parse(doubler)).to eq(described_class.new(variants: ["CountersYouPutDoubler"]))
    expect(described_class.parse(halver)).to eq(described_class.new(variants: ["CountersOpponentPutHalver"]))
  end

  it "ignores other lines" do
    expect(described_class.parse("Trample, haste")).to be_nil
  end

  it "merges both variants into one replacement_effects method" do
    merged = described_class.merge([described_class.parse(doubler), described_class.parse(halver)])
    expect(merged.size).to eq(1)
    expect(merged.first.body_source).to eq(
      "def replacement_effects = [ReplacementEffect::CountersYouPutDoubler, ReplacementEffect::CountersOpponentPutHalver].flat_map(&:registrations)\n"
    )
  end
end
