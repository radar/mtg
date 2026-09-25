# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::CostReduction do
  it "parses reductions for all spells, one type, a non-type, or two types" do
    expect(described_class.parse("Spells you cast cost {1} less to cast.")).to eq(described_class.new([], 1))
    expect(described_class.parse("Creature spells you cast cost {2} less to cast.")).to eq(described_class.new(["creature"], 2))
    expect(described_class.parse("Instant and sorcery spells you cast cost {1} less to cast.")).to eq(described_class.new(%w[instant sorcery], 1))
  end

  it "renders a ManaCostAdjustment for the matching spells" do
    source = described_class.new(%w[instant sorcery], 1).class_source("CostReduction")
    expect(source).to include("class CostReduction < Abilities::Static::ManaCostAdjustment", "adjustment: { generic: -1 }",
                              '->(card) { card.type?("Instant") || card.type?("Sorcery") }')
    expect(described_class.new(["noncreature"], 1).class_source("X")).to include('!card.type?("Creature")')
    expect(described_class.new([], 1).class_source("X")).to include("->(card) { true }")
  end

  it "ignores other lines" do
    expect(described_class.parse("Spells your opponents cast cost {1} more to cast.")).to be_nil
  end
end
