require "spec_helper"

RSpec.describe Magic::Cards::BifurMelodicRider do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:bifur) { ResolvePermanent("Bifur, Melodic Rider", owner: p1) }

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 4/5" do
    expect([bifur.power, bifur.toughness]).to eq([4, 5])
  end

  it "puts a +1/+1 counter on target creature when it enters" do
    game.resolve_choice!(target: bears)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "puts a +1/+1 counter on target creature whenever it attacks" do
    game.resolve_choice!(target: bears)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bifur, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.resolve_choice!(target: bifur)
    game.tick!

    expect(plus_counters(bifur)).to eq(1)
  end

  it "triggers its own enters ability once without an enduring story" do
    game.resolve_choice!(target: bears)

    expect(Magic::Storied.enduring_story?(p1)).to be(false)
    expect(game.choices).to be_empty
  end

  def hones(equipment) = equipment.counters.of_type(Magic::Counters::Hone).count

  it "triggers a Dwarf's ability an additional time with an enduring story" do
    game.resolve_choice!(target: bears)
    spatulas = Array.new(3) { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    game.tick!
    expect(Magic::Storied.enduring_story?(p1)).to be(true)

    ResolvePermanent("Dwalin, Weaponmaster", owner: p1)

    expect(spatulas.map { hones(_1) }).to eq([2, 2, 2])
  end

  it "does not double a Dwarf an opponent controls" do
    game.resolve_choice!(target: bears)
    3.times { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    game.tick!
    opp_spatula = ResolvePermanent("Well-Worn Spatula", owner: p2)

    ResolvePermanent("Dwalin, Weaponmaster", owner: p2)

    expect(hones(opp_spatula)).to eq(1)
  end
end
