# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::DealDamageTwoTargets do
  let(:text) { "~ deals 2 damage to any target and 1 damage to any other target." }

  it "parses two damage amounts" do
    expect(described_class.parse(text)).to eq(described_class.new(2, 1))
  end

  it "renders a multi-target spell with distinct targets" do
    source = Magic::CardParser::EffectList.parse(text).spell_source
    expect(source).to include("def multi_target? = true", "def distinct_targets? = true",
                              "[game.any_target, game.any_target]", "def resolve!(targets:)")
  end

  it "isn't supported in triggered abilities" do
    expect { Magic::CardParser::EffectList.parse(text).trigger_source }.to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
