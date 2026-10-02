# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IcewindElemental do
  include_context "two player game"

  it "is a 3/4 flyer" do
    elemental = ResolvePermanent("Icewind Elemental", owner: p1)

    expect([elemental.power, elemental.toughness]).to eq([3, 4])
    expect(elemental).to be_flying
  end

  it "draws a card, then discards a card when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Icewind Elemental", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
    discarded = p1.hand.first
    game.resolve_choice!(card: discarded)

    expect(p1.hand.count).to eq(hand_size)
    expect(discarded.zone).to be_graveyard
  end
end
