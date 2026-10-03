# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::DamageDoubler do
  it "parses the creature version (Gratuitous Violence)" do
    rule = described_class.parse("If a creature you control would deal damage to a permanent or player, it deals double that damage instead.")
    expect(rule.body_source).to eq("def replacement_effects = ReplacementEffect::CreatureDamageDoubler.registrations\n")
  end

  it "parses the opponent version (Twinflame Tyrant)" do
    rule = described_class.parse("If a source you control would deal damage to an opponent or a permanent an opponent controls, it deals double that damage instead.")
    expect(rule.body_source).to eq("def replacement_effects = ReplacementEffect::OpponentDamageDoubler.registrations\n")
  end

  it "ignores other damage replacements" do
    expect(described_class.parse("If a source would deal damage to you, prevent that damage.")).to be_nil
    expect(described_class.parse("If a source you control would deal damage to a player, it deals triple that damage instead.")).to be_nil
  end
end
