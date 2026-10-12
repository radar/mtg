# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BonePitBrute do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:brute) { ResolvePermanent("Bone Pit Brute", owner: p1) }

  it "is a 4/5 Cyclops with menace" do
    expect([brute.power, brute.toughness]).to eq([4, 5])
    expect(brute.has_keyword?(Magic::Cards::Keywords::MENACE)).to eq(true)
  end

  it "gives target creature +4/+0 until end of turn when it enters" do
    game.settle!
    game.resolve_choice!(target: bears)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([6, 2])
  end

  it "can target itself or an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!
    game.resolve_choice!(target: theirs)
    game.tick!

    expect(theirs.power).to eq(6)
  end

  it "wears off at end of turn" do
    game.settle!
    game.resolve_choice!(target: bears)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
