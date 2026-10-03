# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::AdditionalCost do
  it "parses sacrificing a permanent of a type" do
    rule = described_class.parse("As an additional cost to cast ~, sacrifice a creature.")

    expect(rule).to eq(described_class.new(:sacrifice, "creature"))
    expect(rule.body_source).to include("def additional_costs", "Costs::Sacrifice.new(self, (controller || owner).creatures)")
    expect(described_class.parse("As an additional cost to cast ~, sacrifice an artifact.").body_source).to include("artifacts")
  end

  it "parses discarding a card" do
    rule = described_class.parse("As an additional cost to cast ~, discard a card.")

    expect(rule.body_source).to include("Costs::Discard.new(controller || owner)")
  end

  it "ignores other additional costs" do
    expect(described_class.parse("As an additional cost to cast ~, behold a Dragon.")).to be_nil
    expect(described_class.parse("As an additional cost to cast ~, sacrifice a Goblin.")).to be_nil
  end
end
