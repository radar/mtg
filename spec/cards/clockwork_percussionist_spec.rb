# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClockworkPercussionist do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:percussionist) { ResolvePermanent("Clockwork Percussionist", owner: p1) }

  it "is a 1/1 hasty Monkey Toy artifact creature" do
    expect([percussionist.power, percussionist.toughness]).to eq([1, 1])
    expect(percussionist).to be_haste
    expect(percussionist.artifact?).to be(true)
    expect(percussionist.type?("Monkey")).to be(true)
  end

  it "exiles the top card when it dies and lets you play it until the end of your next turn" do
    top = p1.library.first
    percussionist.destroy!
    game.settle!

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
    expect(game.play_permissions.permits?(top, p2)).to be(false)
  end

  it "the permission lasts through your next turn, then ends" do
    top = p1.library.first
    percussionist.destroy!
    game.settle!
    game.next_turn
    game.next_turn
    go_to_main_phase!
    expect(game.play_permissions.permits?(top, p1)).to be(true)

    game.next_turn
    game.next_turn
    go_to_main_phase!
    expect(game.play_permissions.permits?(top, p1)).to be(false)
  end
end
