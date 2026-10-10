# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FriendlyTeddy do
  include_context "two player game"

  it "is a 2/2 artifact creature" do
    teddy = ResolvePermanent("Friendly Teddy", owner: p1)

    expect([teddy.power, teddy.toughness]).to eq([2, 2])
    expect(teddy.type?("Artifact")).to be(true)
  end

  it "makes each player draw a card when it dies" do
    teddy = ResolvePermanent("Friendly Teddy", owner: p1)
    hand1 = p1.hand.count
    hand2 = p2.hand.count
    teddy.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand1 + 1)
    expect(p2.hand.count).to eq(hand2 + 1)
  end
end
