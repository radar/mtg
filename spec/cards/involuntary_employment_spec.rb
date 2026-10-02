# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InvoluntaryEmployment do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    rival.tap!
    p1.add_mana(red: 4)
    p1.cast(card: Card("Involuntary Employment", owner: p1)) { |a| a.pay_mana(generic: { red: 3 }, red: 1).targeting(rival) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "gains control of target creature, untaps it and gives it haste" do
    expect(rival.controller).to eq(p1)
    expect(rival).not_to be_tapped
    expect(rival).to be_haste
  end

  it "creates a Treasure token" do
    expect(p1.permanents.by_name("Treasure").count).to eq(1)
  end

  it "returns the creature at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(rival.controller).to eq(p2)
  end
end
