# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HelpfulHunter do
  include_context "two player game"

  it "is a 1/1 Cat" do
    hunter = ResolvePermanent("Helpful Hunter", owner: p1)

    expect([hunter.power, hunter.toughness]).to eq([1, 1])
  end

  it "draws a card when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Helpful Hunter", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
