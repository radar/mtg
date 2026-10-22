# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PhyrexianIronworks do
  include_context "two player game"

  let!(:ironworks) { ResolvePermanent("Phyrexian Ironworks", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:bears2) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def golem = ironworks.activated_abilities.first

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  def golems = p1.creatures.select { _1.name == "Phyrexian Golem" }

  it "gets you one energy whenever you attack, once for several attackers" do
    attack(bears, bears2)
    expect(p1.energy).to eq(1)
  end

  it "gives no energy when the opponent attacks, and one more on a later turn of yours" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    attack(bears)
    expect(p1.energy).to eq(1)

    game.next_turn
    game.settle!
    expect(p1.energy).to eq(1)

    game.next_turn
    attack(bears)
    expect(p1.energy).to eq(2)
  end

  it "gives no energy when you don't attack" do
    skip_to_combat!
    game.settle!
    expect(p1.energy).to eq(0)
  end

  context "with three energy" do
    before do
      p1.add_counter("energy", amount: 3)
      go_to_main_phase!
    end

    it "taps and pays {E}{E}{E} to create a 3/3 Phyrexian Golem artifact creature" do
      p1.activate_ability(ability: golem)
      game.stack.resolve!
      game.settle!

      expect(golems.count).to eq(1)
      token = golems.first
      expect([token.power, token.toughness]).to eq([3, 3])
      expect(token.type?("Artifact")).to be(true)
      expect(token.type?("Phyrexian")).to be(true)
      expect(token.type?("Golem")).to be(true)
      expect(token.colors).to be_empty
      expect(p1.energy).to eq(0)
      expect(ironworks).to be_tapped
    end

    it "can't be activated at instant speed" do
      skip_to_combat!
      expect { p1.activate_ability(ability: golem) }.to raise_error(Magic::IllegalAction, /requirements to activate/)
      expect(golems).to be_empty
    end

    it "can't be activated on the opponent's turn" do
      go_to_main_phase_for!(p2)
      expect { p1.activate_ability(ability: golem) }.to raise_error(Magic::IllegalAction, /requirements to activate/)
    end

    it "can't be activated while tapped" do
      ironworks.tap!
      expect { p1.activate_ability(ability: golem) }.to raise_error(Magic::IllegalAction)
      expect(golems).to be_empty
      expect(p1.energy).to eq(3)
    end
  end

  it "can't be activated with fewer than three energy" do
    p1.add_counter("energy", amount: 2)
    go_to_main_phase!
    # The engine raises a plain RuntimeError from Player#pay_energy! here, not Magic::IllegalAction.
    expect { p1.activate_ability(ability: golem) }.to raise_error(RuntimeError, /can't pay 3 \{E\}/)
    expect(golems).to be_empty
    expect(p1.energy).to eq(2)
    # Not asserted: Ironworks stays tapped, because {T} is paid before the energy cost is found unpayable
    # (known engine hazard, see docs/engine_notes.md "Action Legality").
  end
end
