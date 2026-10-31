# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HaradrimSpearmaster do
  include_context "two player game"

  let!(:spearmaster) { ResolvePermanent("Haradrim Spearmaster", owner: p1) }

  def begin_combat(player)
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: player))
    game.settle!
  end

  it "is a 2/3 Human Warrior with reach" do
    expect([spearmaster.power, spearmaster.toughness]).to eq([2, 3])
    expect(spearmaster).to be_reach
  end

  it "gives a lone other creature +1/+0 at the beginning of your combat" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    begin_combat(p1)
    game.tick!

    expect(bears.power).to eq(3)
    expect(spearmaster.power).to eq(2)
  end

  it "lets you choose among several other creatures you control, never itself or opposing creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    angel = ResolvePermanent("Serra Angel", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    begin_combat(p1)

    expect(game.choices.first.choices).to contain_exactly(bears, angel)
    game.resolve_choice!(target: angel)
    game.tick!

    expect(angel.power).to eq(5)
    expect(bears.power).to eq(2)
    expect(theirs.power).to eq(2)
  end

  it "wears off at end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    begin_combat(p1)
    game.tick!
    current_turn.end!
    current_turn.cleanup!

    expect(bears.power).to eq(2)
  end

  it "must pick a target: skipping the choice pumps the first legal creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Serra Angel", owner: p1)
    begin_combat(p1)
    game.skip_choice!
    game.tick!

    expect(bears.power).to eq(3)
  end

  it "does nothing with no other creature" do
    begin_combat(p1)

    expect(game.choices).to be_empty
    expect(spearmaster.power).to eq(2)
  end

  it "doesn't trigger on an opponent's turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Serra Angel", owner: p1)
    begin_combat(p2)

    expect(game.choices).to be_empty
  end
end
