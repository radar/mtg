# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MonstrousEmergence do
  include_context "two player game"

  let(:emergence) { Card("Monstrous Emergence", owner: p1) }
  let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) }

  before do
    p1.hand.add(emergence)
    go_to_main_phase!
  end

  it "deals damage equal to the power of a creature you chose" do
    giant = ResolvePermanent("Bedhead Beastie", owner: p1)
    p1.add_mana(green: 2)
    p1.cast(card: emergence) do |a|
      a.pay_mana(generic: { green: 1 }, green: 1).pay_behold(giant).targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(p1.creatures).to include(giant)
  end

  it "deals damage equal to the power of a creature card revealed from hand" do
    elves = Card("Wood Elves", owner: p1)
    p1.hand.add(elves)
    p1.add_mana(green: 2)
    p1.cast(card: emergence) do |a|
      a.pay_mana(generic: { green: 1 }, green: 1).pay_behold(elves).targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(victim.damage).to eq(1)
    expect(p1.hand.cards).to include(elves)
  end

  it "can't be cast with no creature to choose or reveal" do
    p1.hand.cards.select(&:creature?).each { p1.hand.remove(_1) }

    expect(emergence.additional_costs.first.can_pay?(p1)).to be(false)
  end
end
