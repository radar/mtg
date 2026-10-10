# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PatchedPlaything do
  include_context "two player game"

  before { go_to_main_phase! }

  it "is a 4/3 double strike artifact creature" do
    toy = ResolvePermanent("Patched Plaything", owner: p1)

    expect([toy.power, toy.toughness]).to eq([4, 3])
    expect(toy).to be_double_strike
  end

  it "enters with two -1/-1 counters when cast from hand" do
    card = Card("Patched Plaything", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.tick!
    toy = p1.creatures.find { _1.card == card }

    expect([toy.power, toy.toughness]).to eq([2, 1])
  end
end
