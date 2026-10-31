# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LashOfTheBalrog do
  include_context "two player game"

  let(:lash) { Card("Lash Of The Balrog",owner: p1) }
  let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) }

  before do
    p1.hand.add(lash)
    go_to_main_phase!
  end

  def cast_with(additional_payment, target: victim, mana: 1)
    p1.add_mana(black: mana)
    p1.cast(card: lash) do |action|
      action.pay_mana(black: 1)
      action.pay_additional_cost(Magic::Costs::SacrificeOrMana, additional_payment)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys target creature, sacrificing a creature as the additional cost" do
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with(fodder)

    expect(fodder.card.zone).to be_graveyard
    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(lash.zone).to be_graveyard
  end

  it "can instead be cast by paying {4} more" do
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with({ generic: { black: 4 } }, mana: 5)

    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(p1.creatures).to include(fodder)
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "cannot be cast with less than {4} and no sacrifice" do
    expect { cast_with({ generic: { black: 3 } }, mana: 4) }.to raise_error(StandardError)
    expect(p2.creatures).to include(victim)
  end

  it "cannot target a hexproof creature" do
    shark = ResolvePermanent("Spined Megalodon", owner: p2)
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { cast_with(fodder, target: shark) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    expect(p2.creatures).to include(shark)
  end
end
