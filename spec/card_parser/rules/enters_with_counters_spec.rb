# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::EntersWithCounters do
  it "parses both wordings and any known counter type" do
    expect(described_class.parse("~ enters with two +1/+1 counters on it.")).to eq(described_class.new(2, "+1/+1"))
    expect(described_class.parse("~ enters the battlefield with a +1/+1 counter on it.")).to eq(described_class.new(1, "+1/+1"))
    expect(described_class.parse("~ enters with three time counters on it.")).to eq(described_class.new(3, "time"))
  end

  it "ignores unknown counters" do
    expect(described_class.parse("~ enters with three charge counters on it.")).to be_nil
  end

  it "renders the enters_with_counters macro, +1/+1 counters on creatures only" do
    expect(described_class.new(2, "+1/+1").body_source).to eq("enters_with_counters \"+1/+1\", 2\n")
    expect(described_class.new(2, "+1/+1").kinds).to eq(%i[creature])
    expect(described_class.new(3, "time").kinds).to include(:enchantment)
  end
end
