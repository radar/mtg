# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PropagatorDrone do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:drone) { ResolvePermanent("Propagator Drone", owner: p1) }

  def spawns(player = p1) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  def make_spawn
    p1.add_mana(green: 4)
    p1.activate_ability(ability: drone.activated_abilities.first) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a devoid 2/2 Eldrazi Drone" do
    expect(Card("Propagator Drone", owner: p1).colors).to be_empty
    expect([drone.power, drone.toughness]).to eq([2, 2])
  end

  it "creates an Eldrazi Spawn token for {3}{G}" do
    make_spawn

    expect(spawns.size).to eq(1)
    expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
  end

  it "gives your creature tokens evolve: a bigger creature entering puts a +1/+1 counter on the token" do
    make_spawn
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect([spawns.first.power, spawns.first.toughness]).to eq([1, 2])
  end

  it "does not grow a token when the entering creature is no bigger" do
    make_spawn
    ResolvePermanent("Birds Of Paradise", owner: p1)
    game.settle!

    expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
  end

  it "does not grow a token for an opponent's creature" do
    make_spawn
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!

    expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
  end

  it "does not give evolve to nontoken creatures" do
    small = ResolvePermanent("Birds Of Paradise", owner: p1)
    ResolvePermanent("Serra Angel", owner: p1)
    game.settle!

    expect([small.power, small.toughness]).to eq([0, 1])
    expect([drone.power, drone.toughness]).to eq([2, 2])
  end
end
