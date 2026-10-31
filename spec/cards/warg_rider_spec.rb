# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WargRider do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:rider) { ResolvePermanent("Warg Rider", owner: p1) }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 4/3 Orc Warrior with menace" do
    expect([rider.power, rider.toughness]).to eq([4, 3])
    expect(rider.type?("Orc")).to eq(true)
    expect(rider).to be_menace
  end

  it "gives other Orcs and Goblins you control menace" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.tick!

    expect(goblin).to be_menace
    expect(bears).not_to be_menace
  end

  it "does not give menace to opposing Orcs and Goblins" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p2)
    game.tick!

    expect(goblin).not_to be_menace
  end

  it "gives an Orc Army menace once amassed" do
    skip_to_combat!
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!

    expect(armies.first).to be_menace
  end

  it "amasses Orcs 2 at the beginning of combat on your turn" do
    skip_to_combat!
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(2)
    expect(armies.first.type?("Orc")).to eq(true)
  end

  it "does not amass at the beginning of combat on an opponent's turn" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(armies).to be_empty
  end
end
