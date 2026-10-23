# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmissaryOfSoulfire do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:emissary) { ResolvePermanent("Emissary Of Soulfire", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { game.settle! }

  def add_exalted(target)
    p1.activate_ability(ability: emissary.activated_abilities.first) { _1.targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "gives three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  it "pays two energy to put an exalted counter on a creature you control" do
    add_exalted(bears)

    expect(p1.energy).to eq(1)
    expect(bears.counters.of_type(Magic::Counters::Exalted).count).to eq(1)
  end

  it "cannot be activated without enough energy" do
    add_exalted(bears)

    expect { add_exalted(bears) }.to raise_error(/can't pay 2/)
  end

  it "only offers creatures you control as targets" do
    opposing = ResolvePermanent("Grizzly Bears", owner: p2)
    targets = emissary.activated_abilities.first.target_choices.to_a

    expect(targets).to include(bears)
    expect(targets).not_to include(opposing)
  end

  it "can only be activated as a sorcery" do
    skip_to_combat!

    expect { add_exalted(bears) }.to raise_error(Magic::IllegalAction)
  end

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.tick!
    game.stack.resolve! until game.stack.empty?
    game.settle!
  end

  it "gives +1/+1 to a creature attacking alone for each exalted counter among your permanents" do
    add_exalted(bears)
    emissary.add_counter("exalted")
    attack_with(bears)

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "does nothing when more than one creature attacks" do
    add_exalted(bears)
    attack_with(bears, emissary)

    expect([bears.power, bears.toughness]).to eq([2, 2])
  end
end
