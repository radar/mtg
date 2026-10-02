# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArcaneEpiphany do
  include_context "two player game"

  it "draws three cards" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 5)
    p1.cast(card: Card("Arcane Epiphany", owner: p1)) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 3)
  end

  it "costs {1} less with a Wizard" do
    ResolvePermanent("Archmage Of Runes", owner: p1) # a Giant Wizard that also reduces instants
    game.tick!
    hand_size = p1.hand.count
    p1.add_mana(blue: 3)
    p1.cast(card: Card("Arcane Epiphany", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 2) }
    game.stack.resolve!

    expect(p1.hand.count).to be > hand_size
  end
end
