# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PiratesCutlass do
  include_context "two player game"

  let!(:pirate) { ResolvePermanent("Storm Fleet Spy", owner: p1) }

  it "gives equipped creature +2/+1" do
    cutlass = ResolvePermanent("Pirate's Cutlass", owner: p1)
    game.settle!
    game.tick!

    expect(cutlass.attached_to).to eq(pirate)
    expect([pirate.power, pirate.toughness]).to eq([4, 3])
  end

  it "attaches to the only Pirate you control as it enters" do
    cutlass = ResolvePermanent("Pirate's Cutlass", owner: p1)
    game.settle!

    expect(cutlass.attached_to).to eq(pirate)
  end

  it "lets you choose between Pirates" do
    other = ResolvePermanent("Skyship Buccaneer", owner: p1)
    cutlass = ResolvePermanent("Pirate's Cutlass", owner: p1)
    game.settle!
    game.resolve_choice!(target: other)

    expect(cutlass.attached_to).to eq(other)
  end

  it "does not attach to a non-Pirate or the opponent's Pirate" do
    pirate.destroy!
    game.settle!
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Storm Fleet Spy", owner: p2)
    cutlass = ResolvePermanent("Pirate's Cutlass", owner: p1)
    game.settle!

    expect(cutlass.attached_to).to be_nil
    expect(game.choices).to be_empty
  end
end
