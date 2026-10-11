# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StormfistCrusader do
  include_context "two player game"

  let!(:crusader) { ResolvePermanent("Stormfist Crusader", owner: p1) }

  it "has menace" do
    expect(crusader).to have_keyword(:menace)
  end

  it "makes each player draw a card and lose 1 life at its controller's upkeep" do
    h1 = p1.hand.cards.count
    h2 = p2.hand.cards.count
    current_turn.untap!
    current_turn.upkeep!
    game.settle!

    expect(p1.hand.cards.count).to eq(h1 + 1)
    expect(p2.hand.cards.count).to eq(h2 + 1)
    expect([p1.life, p2.life]).to eq([19, 19])
  end

  it "does nothing at the opponent's upkeep" do
    game.next_turn
    current_turn.untap!
    current_turn.upkeep!
    game.settle!

    expect([p1.life, p2.life]).to eq([20, 20])
  end
end
