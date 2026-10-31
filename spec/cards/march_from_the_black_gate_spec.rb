# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarchFromTheBlackGate do
  include_context "two player game"

  before { go_to_main_phase! }

  def armies_of(player) = player.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def attack_with(creature, player: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: player == p1 ? p2 : p1)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
  end

  let(:march) { ResolvePermanent("March From The Black Gate", owner: p1) }

  it "amasses Orcs 1 when it enters, creating a 0/0 black Orc Army with a counter" do
    march
    expect(armies_of(p1).size).to eq(1)
    army = armies_of(p1).first
    expect(army.type?("Orc")).to eq(true)
    expect(counters(army)).to eq(1)
    expect(army.power).to eq(1)
  end

  it "puts a counter on an existing Army instead of making a second one when it enters" do
    existing = Magic::Amass.call(source: ResolvePermanent("Grizzly Bears", owner: p1), controller: p1, amount: 2)
    game.settle!
    march
    expect(armies_of(p1)).to eq([existing])
    expect(counters(existing)).to eq(3)
    expect(existing.type?("Orc")).to eq(true)
  end

  it "amasses Orcs 1 whenever an Army you control attacks" do
    march
    army = armies_of(p1).first
    army.controlled_since_turn = 0
    game.tick!

    attack_with(army)

    expect(counters(army)).to eq(2)
    expect(armies_of(p1).size).to eq(1)
  end

  it "does not trigger when a non-Army creature attacks" do
    march
    army = armies_of(p1).first
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    attack_with(bears)

    expect(counters(army)).to eq(1)
  end

  it "does not trigger when an opponent's Army attacks" do
    march
    army = armies_of(p1).first
    opp_army = Magic::Amass.call(source: march, controller: p2, amount: 1)
    opp_army.controlled_since_turn = 0
    game.settle!
    go_to_main_phase_for!(p2)

    attack_with(opp_army, player: p2)

    expect(counters(army)).to eq(1)
    expect(counters(opp_army)).to eq(1)
  end
end
