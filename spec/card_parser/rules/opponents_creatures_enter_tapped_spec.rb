# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::OpponentsCreaturesEnterTapped do
  it "parses the static ability" do
    rule = described_class.parse("Creatures your opponents control enter tapped.")

    expect(rule).to be_a(described_class)
    expect(rule.hook).to eq(:static_abilities)
    expect(rule.class_source("EnterTapped")).to include("def forces_creature_to_enter_tapped?(_card, player) = player != controller")
  end

  it "ignores other lines" do
    expect(described_class.parse("Creatures you control enter tapped.")).to be_nil
  end
end
