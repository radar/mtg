# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::Behold do
  it "parses \"behold a <creature type>\" into a Choice::Behold with a guard" do
    effect = described_class.parse("Behold a Dragon.")

    expect(effect.type).to eq("Dragon")
    expect(effect.choice_base).to eq("Magic::Choice::Behold")
    expect(effect.choice_guard).to include('type: "Dragon"').and include(".candidates.any?")
  end

  it "ignores unknown types and other sentences" do
    expect(described_class.parse("Behold a Wibble.")).to be_nil
    expect(described_class.parse("Draw a card.")).to be_nil
  end

  it "joins \"you may behold a Dragon. If you do, ...\" into the choice followed by the effect" do
    list = Magic::CardParser::EffectList.parse("You may behold a Dragon. If you do, create a Treasure token.")

    expect(list.effects.first).to be_a(described_class)
    expect(list.effects.size).to eq(2)
  end
end

RSpec.describe Magic::CardParser::Effects::BecomeTypeInAddition do
  it "parses the type, the keywords and the optional \"until end of turn\" wording" do
    effect = described_class.parse("Until end of turn, ~ becomes a Dragon in addition to its other types and gains flying.")
    expect(effect.type).to eq("Dragon")
    expect(effect.keywords).to eq([:flying])
    expect(effect.resolve_call).to include('add_types(T::Creatures["Dragon"])')

    expect(described_class.parse("~ becomes a Dragon in addition to its other types until end of turn.").keywords).to eq([])
  end

  it "ignores other types" do
    expect(described_class.parse("~ becomes a Wibble in addition to its other types.")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Effects::Bite do
  it "parses the two-target form" do
    effect = described_class.parse("Target creature you control deals damage equal to its power to target creature or planeswalker.")

    expect(effect.multi_target?).to be(true)
    expect(effect.target_choices).to include("battlefield.controlled_by(controller).creatures").and include("planeswalkers")
    expect(effect.resolve_call).to include("biter.bite!(victim)")
  end

  it "parses a creature-only victim" do
    effect = described_class.parse("Target creature you control deals damage equal to its power to target creature.")

    expect(effect.target_choices).not_to include("planeswalkers")
  end

  it "parses a victim the caster doesn't control" do
    effect = described_class.parse("Target creature you control deals damage equal to its power to target creature or planeswalker you don't control.")

    expect(effect.target_choices).to include("battlefield.not_controlled_by(controller).creatures")
      .and include("battlefield.not_controlled_by(controller).planeswalkers")
  end

  it "parses \"creature an opponent controls\"" do
    effect = described_class.parse("Target creature you control deals damage equal to its power to target creature an opponent controls.")

    expect(effect.target_choices).to end_with("battlefield.not_controlled_by(controller).creatures]")
  end
end

RSpec.describe Magic::CardParser::EffectList do
  it "reads \"If a Dragon was beheld, ...\" as a kicker-style conditional effect" do
    list = described_class.parse("~ deals 5 damage to target attacking or blocking creature. If a Dragon was beheld, you gain 2 life.")

    expect(list.effects.last).to be_a(Magic::CardParser::KickedEffect)
    expect(list.spell_source).to include("if kicker_cost.paid?")
  end
end
