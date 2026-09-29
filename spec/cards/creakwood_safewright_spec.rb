# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CreakwoodSafewright do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:safewright) { ResolvePermanent("Creakwood Safewright", owner: p1) }

  def counters = safewright.counters.of_type(Magic::Counters::Minus1Minus1).count

  def end_step!
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
    game.settle!
  end

  it "enters with three -1/-1 counters, so it is a 2/2" do
    game.tick!

    expect(counters).to eq(3)
    expect([safewright.power, safewright.toughness]).to eq([2, 2])
  end

  it "removes a counter at your end step if there is an Elf card in your graveyard" do
    p1.graveyard.add(Card("Skyway Sniper", owner: p1))
    end_step!

    expect(counters).to eq(2)
  end

  it "does nothing without an Elf card in your graveyard" do
    end_step!

    expect(counters).to eq(3)
  end

  it "does nothing at the opponent's end step" do
    p1.graveyard.add(Card("Skyway Sniper", owner: p1))
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p2))
    game.settle!

    expect(counters).to eq(3)
  end

  it "does not count an Elf card in the opponent's graveyard" do
    p2.graveyard.add(Card("Skyway Sniper", owner: p2))
    end_step!

    expect(counters).to eq(3)
  end
end
