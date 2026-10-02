# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScorchingDragonfire do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_at(target)
    p1.add_mana(red: 2)
    p1.cast(card: Card("Scorching Dragonfire", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "deals 3 damage to target creature and exiles it instead of letting it die" do
    cast_at(rival)

    expect(game.exile.cards).to include(rival.card)
    expect(p2.graveyard.cards).not_to include(rival.card)
  end

  it "doesn't exile a creature that survives" do
    big = ResolvePermanent("Fire Elemental", owner: p2) # 5/4
    cast_at(big)

    expect(big.zone).to be_battlefield
    expect(big.damage).to eq(3)
  end

  it "can't target a player" do
    p1.add_mana(red: 2)

    expect { p1.cast(card: Card("Scorching Dragonfire", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(p2) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
