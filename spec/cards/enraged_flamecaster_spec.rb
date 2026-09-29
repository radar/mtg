# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnragedFlamecaster do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:flamecaster) { ResolvePermanent("Enraged Flamecaster", owner: p1) }

  it "is a 3/2 reach Elemental Sorcerer" do
    expect([flamecaster.power, flamecaster.toughness]).to eq([3, 2])
    expect(flamecaster).to be_reach
  end

  it "deals 2 damage to each opponent when you cast a spell with mana value 4 or greater" do
    card = Card("Kinbinding", owner: p1) # mana value 5
    p1.hand.add(card)
    p1.add_mana(white: 5)
    p1.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 2) }
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
  end

  it "does nothing for a cheaper spell" do
    card = Card("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "does nothing when the opponent casts a big spell" do
    go_to_main_phase_for!(p2)
    card = Card("Kinbinding", owner: p2)
    p2.hand.add(card)
    p2.add_mana(white: 5)
    p2.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 2) }
    game.settle!

    expect(p2.life).to eq(20)
  end
end
