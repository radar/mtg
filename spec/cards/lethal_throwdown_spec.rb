# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LethalThrowdown do
  include_context "two player game"

  let!(:fodder) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) }

  before { go_to_main_phase! }

  def throw!
    p1.add_mana(black: 1)
    p1.cast(card: Card("Lethal Throwdown", owner: p1)) do |a|
      a.pay_mana(black: 1)
      a.pay_sacrifice(fodder)
      a.targeting(victim)
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys the target without drawing when the sacrificed creature is not modified" do
    hand = p1.hand.count
    throw!

    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(p1.hand.count).to eq(hand)
  end

  it "draws a card when the sacrificed creature was modified" do
    fodder.add_counter("+1/+1")
    hand = p1.hand.count
    throw!

    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(p1.hand.count).to eq(hand + 1)
  end
end
