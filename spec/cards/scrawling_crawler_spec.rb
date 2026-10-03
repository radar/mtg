# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScrawlingCrawler do
  include_context "two player game"

  let!(:crawler) { ResolvePermanent("Scrawling Crawler", owner: p1) }

  it "is a 3/2 Phyrexian Construct artifact creature" do
    expect([crawler.power, crawler.toughness]).to eq([3, 2])
    expect(crawler.type?("Artifact")).to be(true)
    expect(crawler.type?("Phyrexian")).to be(true)
  end

  it "has each player draw a card at the beginning of your upkeep" do
    p1_hand = p1.hand.count
    p2_hand = p2.hand.count
    current_turn.untap!
    current_turn.upkeep!

    expect(p1.hand.count).to eq(p1_hand + 1)
    expect(p2.hand.count).to eq(p2_hand + 1)
  end

  it "makes the opponent lose 1 life for the card it makes them draw, but not you" do
    current_turn.untap!
    current_turn.upkeep!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "makes an opponent lose 1 life whenever they draw a card" do
    expect { p2.draw!; game.settle! }.to change { p2.life }.by(-1)
    expect { 2.times { p2.draw! }; game.settle! }.to change { p2.life }.by(-2)
  end

  it "does nothing when you draw a card" do
    expect { p1.draw!; game.settle! }.not_to(change { [p1.life, p2.life] })
  end

  it "does not trigger at an opponent's upkeep" do
    p1_hand = p1.hand.count
    p2_hand = p2.hand.count
    go_to_main_phase_for!(p2)

    # Only p2's own draw-step card: no extra draw for either player, and that one costs p2 1 life.
    expect(p1.hand.count).to eq(p1_hand)
    expect(p2.hand.count).to eq(p2_hand + 1)
    expect(p2.life).to eq(19)
  end
end
