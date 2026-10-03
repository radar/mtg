# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonMage do
  include_context "two player game"

  # Room to draw seven more cards after the opening hand.
  def p1_library = 30.times.map { Card("Forest") }
  def p2_library = 30.times.map { Card("Mountain", owner: p2) }

  let!(:mage) { ResolvePermanent("Dragon Mage", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(mage, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 5/5 flying Dragon Wizard" do
    expect([mage.power, mage.toughness]).to eq([5, 5])
    expect(mage).to be_flying
  end

  it "makes each player discard their hand then draw seven cards when it deals combat damage to a player" do
    # a hand that isn't 7 cards, so "draws seven" isn't just "keeps seven"
    [*p1.hand.cards].first(3).each { p1.hand.remove(_1) }
    old_p1 = [*p1.hand.cards]
    old_p2 = [*p2.hand.cards]
    attack

    expect(p2.life).to eq(15)
    expect(p1.hand.count).to eq(7)
    expect(p2.hand.count).to eq(7)
    expect(p1.graveyard.cards.to_a).to include(*old_p1)
    expect(p2.graveyard.cards.to_a).to include(*old_p2)
    expect(p1.hand.cards.to_a & old_p1).to be_empty
    expect(p2.hand.cards.to_a & old_p2).to be_empty
  end

  it "does nothing if it is blocked" do
    blocker = ResolvePermanent("Serra Angel", owner: p2) # flying: can block a flyer
    skip_to_combat!
    hand = [*p1.hand.cards]
    current_turn.declare_attackers!
    current_turn.declare_attacker(mage, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: mage)
    go_to_combat_damage!
    game.settle!

    expect([*p1.hand.cards]).to eq(hand)
  end
end
