# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::RevealTopPutOntoBattlefield do
  let(:text) do
    "Reveal the top X cards of your library. You may put any number of permanent cards with mana value X or less from among them onto the battlefield. " \
      "Then put all cards revealed this way that weren't put onto the battlefield into your graveyard."
  end

  it "reads the Genesis Wave sentence group" do
    effect = Magic::CardParser::Effect.parse(text)
    expect(effect).to be_a(described_class)
    expect(effect.uses_x?).to be(true)
    expect(effect.choice_base).to eq("Magic::Choice::PutOntoBattlefieldFromAmong")
    expect(effect.choice_args.join).to include("first(value_for_x)", "card.permanent?", "card.mana_value <= value_for_x")
  end

  it "reads a creature-only variant" do
    effect = Magic::CardParser::Effect.parse(text.sub("permanent cards", "creature cards"))
    expect(effect.choice_args.join).to include('card.type?("Creature")')
  end

  it "gives a spell using X a value_for_x argument" do
    source = Magic::CardParser::EffectList.parse(text).spell_source
    expect(source).to include("def resolve!(value_for_x: 0)")
  end
end
