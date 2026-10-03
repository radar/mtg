# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::ExileFromGraveyards do
  def parse(text) = Magic::CardParser::Effect.parse(text)

  it "reads 'up to one target card from a graveyard'" do
    effect = parse("Exile up to one target card from a graveyard.")
    expect(effect.target_choices).to eq("game.graveyard_cards")
    expect(effect.optional_target?).to be(true)
    expect(effect.resolve_call).to eq("trigger_effect(:exile, target: target)")
  end

  it "reads a mandatory target from your or an opponent's graveyard" do
    expect(parse("Exile target card from an opponent's graveyard.").optional_target?).to be(false)
    expect(parse("Exile target card from your graveyard.").target_choices).to eq("controller.graveyard.cards")
  end

  it "reads 'target player's graveyard'" do
    effect = parse("Exile target player's graveyard.")
    expect(effect.target_choices).to eq("game.players")
    expect(effect.resolve_call).to eq("[*target.graveyard.cards].each { trigger_effect(:exile, target: _1) }")
  end

  it "reads up to two cards from a single graveyard with the creature drain" do
    effect = parse("Exile up to two target cards from a single graveyard. If at least one creature card was exiled this way, each opponent loses 2 life and you gain 2 life.")
    expect(effect.max_targets).to eq(2)
    expect(effect.resolve_call).to include("single graveyard", "if exiled.any?(&:creature?)", "life: 2")
  end

  it "doesn't read other exile sentences" do
    expect(parse("Exile target card from a graveyard with flying.")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Effects::TapTarget do
  it "reads 'Tap ~'" do
    effect = Magic::CardParser::Effect.parse("Tap ~.")
    expect(effect.resolve_call).to eq("trigger_effect(:tap, target: #{Magic::CardParser::Effect::THIS})")
    expect(effect.target_choices).to be_nil
    expect(effect.earlier_target?).to be(false)
  end
end

RSpec.describe Magic::CardParser::Rules::ActivatedAbility do
  it "reads 'Sacrifice another creature' as a cost, and 'Tap it' as ~ when nothing is targeted" do
    rule = described_class.parse("Sacrifice another creature: ~ gains indestructible until end of turn. Tap it.")
    expect(rule.costs).to eq("Sacrifice another creature")
    expect(rule.effect_list.effects.last).to be_a(Magic::CardParser::Effects::TapTarget)
  end

  it "leaves 'Tap it' alone when something is targeted" do
    rule = described_class.parse("{2}: Target creature gains flying until end of turn. Tap it.")
    expect(rule.effect_list.effects.last.earlier_target?).to be(true)
  end
end
