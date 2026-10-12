# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StirUpTrouble do
  include_context "two player game"

  let(:trouble) { Card("Stir Up Trouble", owner: p1) }
  let!(:victim) { ResolvePermanent("Ordinary Bear", owner: p2) }

  before do
    p1.hand.add(trouble)
    go_to_main_phase!
  end

  it "destroys target creature, sacrificing a creature as the additional cost" do
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(black: 1)
    p1.cast(card: trouble) do |action|
      action.pay_mana(black: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, fodder)
      action.targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(fodder.card.zone).to be_graveyard
    expect(victim.card.zone).to be_graveyard
  end

  it "accepts an artifact to sacrifice" do
    stone = ResolvePermanent("Mind Stone", owner: p1)
    p1.add_mana(black: 1)
    p1.cast(card: trouble) do |action|
      action.pay_mana(black: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, stone)
      action.targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(stone.card.zone).to be_graveyard
    expect(victim.card.zone).to be_graveyard
  end

  it "can instead be cast by paying {4} more" do
    p1.add_mana(black: 5)
    p1.cast(card: trouble) do |action|
      action.pay_mana(black: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, { generic: { black: 4 } })
      action.targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(victim.card.zone).to be_graveyard
  end

  it "can't be cast without paying the additional cost" do
    p1.add_mana(black: 1)
    expect do
      p1.cast(card: trouble) do |action|
        action.pay_mana(black: 1)
        action.targeting(victim)
      end
    end.to raise_error(StandardError)
  end

  it "won't let you sacrifice a non-artifact, non-creature" do
    forest = ResolvePermanent("Forest", owner: p1)
    p1.add_mana(black: 1)
    expect do
      p1.cast(card: trouble) do |action|
        action.pay_mana(black: 1)
        action.pay_additional_cost(Magic::Costs::SacrificeOrMana, forest)
        action.targeting(victim)
      end
    end.to raise_error(StandardError)
  end
end
