# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiddleGateGargoyle do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:gargoyle) { ResolvePermanent("Riddle Gate Gargoyle", owner: p1) }

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 flying Artifact Creature -- Gargoyle" do
    expect([gargoyle.power, gargoyle.toughness]).to eq([2, 2])
    expect(gargoyle).to be_flying
    expect(gargoyle.type?("Gargoyle")).to be(true)
    expect(gargoyle.artifact?).to be(true)
  end

  it "gives you three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  context "whenever you attack" do
    it "pays {E}{E} to give a creature you control lifelink until end of turn" do
      attack(bears)
      expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
      game.resolve_choice!
      game.resolve_choice!(target: gargoyle)
      game.settle!

      expect(p1.energy).to eq(1)
      expect(gargoyle).to be_lifelink
      expect(bears).not_to be_lifelink
    end

    it "can target a creature you control that isn't attacking" do
      attack(gargoyle)
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(bears).to be_lifelink
    end

    it "loses the lifelink at end of turn" do
      attack(bears)
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      game.settle!
      expect(bears).to be_lifelink

      current_turn.end!
      current_turn.cleanup!
      game.settle!

      expect(bears).not_to be_lifelink
    end

    it "doesn't offer an opponent's creature as a target" do
      opp = ResolvePermanent("Grizzly Bears", owner: p2)
      attack(bears)
      game.resolve_choice!
      game.resolve_choice!(target: gargoyle)

      expect(opp).not_to be_lifelink
    end

    it "does nothing when you decline" do
      attack(bears)
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(3)
      expect(game.choices).to be_empty
      expect(bears).not_to be_lifelink
    end

    it "offers nothing with fewer than two energy" do
      p1.pay_energy!(2)
      attack(bears)

      expect(game.choices).to be_empty
    end

    it "triggers once for several attackers" do
      attack(bears, gargoyle)

      expect(game.choices.count { _1.is_a?(Magic::Choice::PayEnergy) }).to eq(1)
    end

    it "doesn't trigger when you don't attack" do
      skip_to_combat!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
