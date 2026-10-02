# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TatyovaBenthicDruid do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tatyova) { ResolvePermanent("Tatyova, Benthic Druid", owner: p1) }

  it "is a 3/3 legendary Merfolk Druid" do
    expect([tatyova.power, tatyova.toughness]).to eq([3, 3])
  end

  it "gains you 1 life and draws a card when a land enters under your control" do
    hand_size = p1.hand.count
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "doesn't trigger on an opponent's land" do
    go_to_main_phase_for!(p2)
    p2.play_land(land: Card("Mountain", owner: p2))
    game.settle!

    expect(p1.life).to eq(20)
  end
end
