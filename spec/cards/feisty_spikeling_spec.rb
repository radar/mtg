# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FeistySpikeling do
  include_context "two player game"

  let!(:spikeling) { ResolvePermanent("Feisty Spikeling", owner: p1) }

  it "is a 2/1 changeling" do
    expect([spikeling.power, spikeling.toughness]).to eq([2, 1])
    expect(spikeling.type?("Elf")).to be(true)
  end

  it "has first strike during your turn" do
    go_to_main_phase!
    game.tick!

    expect(spikeling).to be_first_strike
  end

  it "does not have first strike during an opponent's turn" do
    go_to_main_phase_for!(p2)
    game.tick!

    expect(spikeling).not_to be_first_strike
  end
end
