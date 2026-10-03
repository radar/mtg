# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HomunculusHorde do
  include_context "two player game"
  # go_to_main_phase! includes the draw step, so the turn's first card is already drawn.
  before { go_to_main_phase! }

  let!(:horde) { ResolvePermanent("Homunculus Horde", owner: p1) }

  def hordes(player = p1) = player.creatures.select { _1.name == "Homunculus Horde" }

  it "is a 2/2 Homunculus" do
    expect([horde.power, horde.toughness]).to eq([2, 2])
  end

  it "creates a token copy of itself when you draw your second card each turn" do
    expect(hordes.size).to eq(1)

    p1.draw!
    game.settle!

    expect(hordes.size).to eq(2)
    expect(hordes.count(&:token?)).to eq(1)
    expect(hordes.last.power).to eq(2)
  end

  it "does not trigger on the third card drawn" do
    2.times { p1.draw! }
    game.settle!

    expect(hordes.size).to eq(2)
  end

  it "does not trigger when the opponent draws their second card" do
    2.times { p2.draw! }
    game.settle!

    expect(hordes.size).to eq(1)
  end

  it "triggers again on your next turn" do
    p1.draw!
    game.settle!
    2.times { game.next_turn }
    go_to_main_phase!
    p1.draw!
    game.settle!

    # The original and its token each trigger once.
    expect(hordes.size).to eq(4)
  end
end
