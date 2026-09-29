# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::ExtraLandDrop do
  it "parses the extra land line into the additional_lands_per_turn macro" do
    rule = described_class.parse("You may play an additional land on each of your turns.")

    expect(rule.body_source).to eq("additional_lands_per_turn 1\n")
    expect(rule.kinds).to include(:enchantment, :creature)
  end

  it "ignores other lines" do
    expect(described_class.parse("You may play two additional lands on each of your turns.")).to be_nil
  end
end
