# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GloomRipper do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 4/4 Elf Assassin" do
    ripper = ResolvePermanent("Gloom Ripper", owner: p1)
    game.choices.clear
    expect([ripper.power, ripper.toughness]).to eq([4, 4])
    expect(ripper.type?("Elf")).to eq(true)
  end

  it "gives your creature +X/+0 and the opponent's -0/-X, X counting Elves you control and Elf cards in your graveyard" do
    ResolvePermanent("Wood Elves", owner: p1)
    p1.graveyard.add(Card("Wood Elves", owner: p1))
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    ResolvePermanent("Wood Elves", owner: p2) # opponent's Elf doesn't count

    ripper = ResolvePermanent("Gloom Ripper", owner: p1)
    # X = Wood Elves + Gloom Ripper on the battlefield + one Elf card in the graveyard = 3
    game.resolve_choice!(target: bears)
    expect(game.choices.last).to be_a(described_class::ETB::OpponentTargetChoice)
    game.resolve_choice!(target: rival)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([5, 2])
    expect([rival.power, rival.toughness]).to eq([2, -1])
    expect(ripper.power).to eq(4)
  end

  it "can target Gloom Ripper itself" do
    ripper = ResolvePermanent("Gloom Ripper", owner: p1)
    game.resolve_choice!(target: ripper)
    game.skip_choice!
    game.tick!

    expect(ripper.power).to eq(5)
    expect(rival.power).to eq(2)
    expect(rival.toughness).to eq(2)
  end

  it "asks for no opponent target when they control no creature" do
    rival.destroy!
    ResolvePermanent("Gloom Ripper", owner: p1)
    game.resolve_choice!(target: bears)
    expect(game.choices).to be_empty
  end

  it "wears off at end of turn" do
    ResolvePermanent("Gloom Ripper", owner: p1)
    game.resolve_choice!(target: bears)
    game.skip_choice!
    game.tick!
    bears.cleanup!
    expect(bears.power).to eq(2)
  end
end
