# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::ConditionalEffect do
  def list(text) = Magic::CardParser::EffectList.parse(text)

  it "parses an 'if there is a <Type> card in your graveyard' sentence after another effect" do
    effects = list("Mill three cards. Then if there is an Elf card in your graveyard, each opponent loses 2 life and you gain 2 life.").effects
    expect(effects.map(&:class)).to eq([Magic::CardParser::Effects::Mill, described_class])
    expect(effects.last.condition).to eq('controller.graveyard.cards.any? { |card| card.type?("Elf") }')
    expect(effects.last.effects.size).to eq(2)
  end

  it "renders the effects inside an if" do
    call = described_class.parse("If there is a Goblin card in your graveyard, draw a card.").resolve_call
    expect(call).to eq(%(if controller.graveyard.cards.any? { |card| card.type?("Goblin") }\n  trigger_effect(:draw_cards, number_to_draw: 1)\nend))
  end

  it "doesn't parse conditional choices or targeted effects" do
    expect(described_class.parse("If there is an Elf card in your graveyard, scry 2.")).to be_nil
    expect(described_class.parse("If there is an Elf card in your graveyard, destroy target creature.")).to be_nil
  end

  it "doesn't parse a condition it doesn't know" do
    expect(described_class.parse("If you control a Goblin, draw a card.")).to be_nil
  end
end
