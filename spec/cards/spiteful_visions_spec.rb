# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpitefulVisions do
  include_context "two player game"

  let!(:visions) { ResolvePermanent("Spiteful Visions", owner: p1) }

  it "costs {2}{B/R}{B/R}" do
    expect(visions.card.mana_value).to eq(4)
  end

  it "deals 1 damage to a player for each card they draw" do
    p1.draw!
    p2.draw!
    p2.draw!
    game.settle!

    expect(p1.life).to eq(19)
    expect(p2.life).to eq(18)
  end

  it "gives each player an additional draw in their draw step" do
    h1 = p1.hand.cards.count
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    game.settle!

    expect(p1.hand.cards.count).to eq(h1 + 2)
    expect(p1.life).to eq(18)
  end

  it "affects the opponent's draw step too" do
    game.next_turn
    h2 = p2.hand.cards.count
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    game.settle!

    expect(p2.hand.cards.count).to eq(h2 + 2)
    expect(p2.life).to eq(18)
  end
end
