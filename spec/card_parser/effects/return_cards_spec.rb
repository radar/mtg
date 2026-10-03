# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::ReturnCards do
  def parse(text) = Magic::CardParser::Effect.parse(text)

  it "reads a single target returned to the battlefield" do
    effect = parse("Return target creature card from your graveyard to the battlefield.")
    expect(effect).to be_a(described_class)
    expect(effect.target_choices).to eq('controller.graveyard.cards.select { _1.type?("Creature") }')
    expect(effect.resolve_call).to eq("trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: target.owner)")
  end

  it "reads mana value filters, including the creature's own power" do
    expect(parse("Return target creature card with mana value 2 or less from your graveyard to the battlefield.").target_choices)
      .to include("_1.mana_value <= 2")
    expect(parse("Return target nonland permanent card with mana value 2 or less from your graveyard to the battlefield.").target_choices)
      .to include("_1.permanent? && !_1.land?")
    panda = parse("Return another target non-Bear creature card with mana value less than or equal to ~'s power from your graveyard to the battlefield.")
    expect(panda.target_choices).to include('!_1.type?("Bear")', "_1.mana_value <= #{Magic::CardParser::Effect::THIS}.power",
                                            "_1 != #{Magic::CardParser::Effect::THIS}.card")
  end

  it "reads up to N targets (resolved with `targets`)" do
    effect = parse("Return up to two target creature cards from your graveyard to your hand.")
    expect(effect.max_targets).to eq(2)
    expect(effect.optional_target?).to be(true)
    expect(effect.resolve_call).to eq("targets.uniq.each { _1.move_to_hand! }")
  end

  it "reads 'all' (untargeted), from your graveyard or all graveyards" do
    mine = parse("Return all creature cards with mana value 2 or less from your graveyard to the battlefield.")
    expect(mine.target_choices).to be_nil
    expect(mine.resolve_call).to start_with("cards = controller.graveyard.cards.select")
    all = parse("Put all creature cards from all graveyards onto the battlefield under your control.")
    expect(all.resolve_call).to include("game.graveyard_cards").and include("controller: controller")
  end

  it "reads a follow-up draw if the card is of a creature type" do
    effect = parse("Return target creature card from your graveyard to your hand. If it's a Zombie card, draw a card.")
    expect(effect.resolve_call).to eq("target.move_to_hand!\ntrigger_effect(:draw_cards, player: controller) if target.type?(\"Zombie\")")
  end

  it "ignores sentences it doesn't understand" do
    expect(parse("Return target creature card from your graveyard to the battlefield tapped.")).to be_nil
    expect(parse("Return all creature cards from a graveyard to the battlefield.")).to be_nil
  end

  it "lets a spell take 'up to two' targets and a trigger take them as a choice" do
    sorcery = Magic::CardParser::EffectList.parse("Return up to two target creature cards from your graveyard to your hand.")
    expect(sorcery.spell_source).to include("def resolve!(targets:)")
    trigger = Magic::CardParser::EffectList.parse("Return up to two target creature cards from your graveyard to your hand.")
    expect(trigger.trigger_source).to include("choice_amount = 0..2")
  end
end
