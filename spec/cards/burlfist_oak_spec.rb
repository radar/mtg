# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurlfistOak do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:oak) { ResolvePermanent("Burlfist Oak", owner: p1) }

  it "is a 2/3 Treefolk" do
    expect([oak.power, oak.toughness]).to eq([2, 3])
  end

  it "gets +2/+2 for each card you draw" do
    2.times { p1.draw! }
    game.settle!

    expect([oak.power, oak.toughness]).to eq([6, 7])
  end

  it "ignores cards the opponent draws" do
    p2.draw!
    game.settle!

    expect([oak.power, oak.toughness]).to eq([2, 3])
  end

  it "wears off at end of turn" do
    p1.draw!
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([oak.power, oak.toughness]).to eq([2, 3])
  end
end
