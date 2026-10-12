# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheGreatGoblin do
  include_context "two player game"

  let!(:goblin) { ResolvePermanent("The Great Goblin", owner: p1) }

  def goblin_army
    Magic::Amass.call(source: goblin, controller: p1, amount: 1)
  end

  it "deals 2 damage to the opponent when counters go on a Goblin Army you control" do
    goblin_army
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "deals 2 damage again for counters put on an existing Army" do
    goblin_army
    game.settle!
    goblin_army
    game.settle!

    expect(p2.life).to eq(16)
  end

  it "ignores counters on non-Goblin/Orc/Army creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.add_counter("+1/+1")
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "ignores counters on an opponent's Army" do
    army = Magic::Amass.call(source: ResolvePermanent("Grizzly Bears", owner: p2), controller: p2, amount: 1)
    game.settle!

    expect(army.controller).to eq(p2)
    expect(p2.life).to eq(20)
  end

  it "exiles the top card and lets you play it when another Goblin, Orc or Army you control dies" do
    army = goblin_army
    game.settle!
    top = p1.library.first
    army.destroy!
    game.settle!

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to eq(true)
  end

  it "does not trigger when The Great Goblin itself dies" do
    top = p1.library.first
    goblin.destroy!
    game.settle!

    expect(top.zone).to eq(p1.library)
  end
end
