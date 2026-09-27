# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Sear do
  include_context "two player game"
  before { p1.add_mana(red: 2) }

  it "deals 4 damage to a target creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    p1.cast(card: Card("Sear", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.damage).to eq(4)
  end

  it "deals 4 damage to a target planeswalker" do
    planeswalker = ResolvePermanent("Wrenn And Seven", owner: p2)
    starting_loyalty = planeswalker.loyalty

    p1.cast(card: Card("Sear", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(planeswalker) }
    game.stack.resolve!

    expect(planeswalker.loyalty).to eq(starting_loyalty - 4)
  end

  it "cannot target a player" do
    card = Card("Sear", owner: p1)
    p1.hand.add(card)

    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(p2) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
