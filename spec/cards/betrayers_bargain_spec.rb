# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BetrayersBargain do
  include_context "two player game"

  let(:bargain) { Card("Betrayer's Bargain", owner: p1) }
  let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) }

  before do
    p1.hand.add(bargain)
    go_to_main_phase!
  end

  def cast_with(additional_payment, mana: 2)
    p1.add_mana(red: mana)
    p1.cast(card: bargain) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, additional_payment)
      action.targeting(victim)
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals 5 damage to target creature, sacrificing a creature as the additional cost, and exiles it" do
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with(fodder)

    expect(fodder.card.zone).to be_graveyard
    expect(game.exile.cards.map(&:name)).to include("Serra Angel")
    expect(p2.graveyard.cards.map(&:name)).not_to include("Serra Angel")
  end

  it "accepts an enchantment to sacrifice" do
    aura = ResolvePermanent("Nowhere To Run", owner: p1)
    game.settle!
    cast_with(aura)

    expect(aura.card.zone).to be_graveyard
  end

  it "can instead be cast by paying {2} more" do
    cast_with({ generic: { red: 2 } }, mana: 4)

    expect(p1.creatures.count).to eq(0)
    expect(game.exile.cards.map(&:name)).to include("Serra Angel")
  end

  it "doesn't exile a creature that survives" do
    survivor = ResolvePermanent("Bedhead Beastie", owner: p2)
    p1.add_mana(red: 4)
    p1.cast(card: bargain) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, { generic: { red: 2 } })
      action.targeting(survivor)
    end
    game.stack.resolve!
    game.settle!

    expect(survivor.damage).to eq(5)
    expect(p2.creatures).to include(survivor)
  end
end
