# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarinaVendrellsGrimoire do
  include_context "two player game"
  before { go_to_main_phase! }

  def grimoire = @grimoire ||= ResolvePermanent("Marina Vendrell's Grimoire", owner: p1, cast: false)

  it "draws five cards when you cast it" do
    card = Card("Marina Vendrell's Grimoire", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: 6)
    hand_before = p1.hand.count
    p1.cast(card: card) { |a| a.pay_mana(generic: { blue: 5 }, blue: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.hand.count).to eq(hand_before - 1 + 5)
  end

  it "doesn't draw when it enters without being cast" do
    hand_before = p1.hand.count
    grimoire
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end

  it "gives you no maximum hand size" do
    grimoire

    expect(p1.maximum_hand_size).to be_nil
  end

  it "draws that many cards when you gain life" do
    grimoire
    hand_before = p1.hand.count
    p1.gain_life(3)
    game.settle!

    expect(p1.hand.count).to eq(hand_before + 3)
  end

  it "doesn't trigger when an opponent gains life" do
    grimoire
    hand_before = p1.hand.count
    p2.gain_life(3)
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end

  it "lets you discard that many cards when you lose life" do
    grimoire
    hand_before = p1.hand.count
    p1.lose_life(2)
    game.settle!
    game.resolve_choice!(cards: p1.hand.cards.first(2))

    expect(p1.hand.count).to eq(hand_before - 2)
    expect(p1).not_to be_lost
  end

  it "loses the game if losing life empties your hand" do
    grimoire
    p1.lose_life(p1.hand.count)
    game.settle!

    expect(p1.hand.count).to eq(0)
    expect(p1).to be_lost
  end

  it "keeps you in the game at 0 or less life" do
    grimoire
    25.times { p1.hand.add(Card("Forest", owner: p1)) }
    p1.lose_life(20)
    game.settle!

    expect(p1.life).to eq(0)
    expect(p1).not_to be_lost
  end
end
