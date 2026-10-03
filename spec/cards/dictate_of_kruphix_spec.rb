# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DictateOfKruphix do
  include_context "two player game"

  let!(:dictate) { ResolvePermanent("Dictate Of Kruphix", owner: p1) }

  it "is a {1}{U}{U} enchantment with flash" do
    card = Card("Dictate Of Kruphix", owner: p1)
    expect(card.cost.cost).to eq(generic: 1, blue: 2)
    expect(card.flash?).to be(true)
  end

  it "makes you draw an additional card in your draw step" do
    hand = p1.hand.count
    go_to_main_phase!

    expect(p1.hand.count).to eq(hand + 2)
  end

  it "makes each opponent draw an additional card in their draw step, too" do
    hand = p2.hand.count
    go_to_main_phase_for!(p2)

    expect(p2.hand.count).to eq(hand + 2)
  end

  it "does not give extra cards outside the draw step" do
    hand = p1.hand.count
    p1.draw!
    game.settle!

    expect(p1.hand.count).to eq(hand + 1)
  end
end
