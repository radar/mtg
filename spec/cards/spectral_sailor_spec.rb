# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpectralSailor do
  include_context "two player game"

  let!(:sailor) { ResolvePermanent("Spectral Sailor", owner: p1) }

  it "is a 1/1 Spirit Pirate with flash and flying" do
    expect([sailor.power, sailor.toughness]).to eq([1, 1])
    expect(sailor.card.has_keyword?(:flash)).to eq(true)
    expect(sailor).to be_flying
  end

  it "draws a card for {3}{U}" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 4)
    p1.activate_ability(ability: sailor.activated_abilities.first) { _1.pay_mana(generic: { blue: 3 }, blue: 1) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
