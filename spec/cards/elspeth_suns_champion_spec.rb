# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElspethSunsChampion do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:elspeth) { ResolvePermanent("Elspeth, Sun's Champion", owner: p1) }

  def activate(index)
    p1.activate_loyalty_ability(ability: elspeth.loyalty_abilities[index])
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def soldiers = p1.creatures.select { _1.name == "Soldier" && _1.token? }

  it "enters with 4 loyalty" do
    expect(elspeth.loyalty).to eq(4)
  end

  it "+1: creates three 1/1 white Soldiers" do
    activate(0)

    expect(elspeth.loyalty).to eq(5)
    expect(soldiers.count).to eq(3)
    expect([soldiers.first.power, soldiers.first.toughness]).to eq([1, 1])
    expect(soldiers.first.colors).to eq([:white])
  end

  it "-3: destroys all creatures with power 4 or greater, on both sides" do
    mine = ResolvePermanent("Baneslayer Angel", owner: p1) # 5/5
    theirs = ResolvePermanent("Baneslayer Angel", owner: p2)
    small = ResolvePermanent("Grizzly Bears", owner: p2)

    activate(1)

    expect(elspeth.loyalty).to eq(1)
    expect(mine.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(theirs.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(small.zone).to be_a(Magic::Zones::Battlefield)
  end

  it "-7: you get an emblem giving your creatures +2/+2 and flying" do
    elspeth.change_loyalty!(7)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    activate(2)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to be_flying
    expect([theirs.power, theirs.toughness]).to eq([2, 2])
    expect(theirs).not_to be_flying
  end

  it "the emblem applies to creatures that arrive later" do
    elspeth.change_loyalty!(7)
    activate(2)
    later = ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect([later.power, later.toughness]).to eq([3, 3])
    expect(later).to be_flying
  end

  it "can't use -7 with only 4 loyalty" do
    expect { p1.activate_loyalty_ability(ability: elspeth.loyalty_abilities[2]) }.to raise_error(Magic::IllegalAction)
  end
end
