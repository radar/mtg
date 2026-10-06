# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LilianasStandardBearer do
  include_context "two player game"

  it "is a 3/1 Zombie Knight with flash" do
    bearer = ResolvePermanent("Liliana's Standard Bearer", owner: p1)
    game.settle!

    expect([bearer.power, bearer.toughness]).to eq([3, 1])
    expect(bearer.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "draws a card for each creature that died under your control this turn" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p1).destroy! }
    game.settle!
    hand_size = p1.hand.count
    ResolvePermanent("Liliana's Standard Bearer", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 2)
  end

  it "doesn't count creatures that died under an opponent's control" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    hand_size = p1.hand.count
    ResolvePermanent("Liliana's Standard Bearer", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand_size)
  end
end
