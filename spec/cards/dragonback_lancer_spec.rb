# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonbackLancer do
  include_context "two player game"

  let!(:lancer) { ResolvePermanent("Dragonback Lancer", owner: p1) }
  def warriors = p1.creatures.select { _1.name == "Warrior" }

  it "is a 3/3 flyer" do
    expect([lancer.power, lancer.toughness]).to eq([3, 3])
    expect(lancer).to have_keyword(Magic::Cards::Keywords::FLYING)
  end

  context "when it attacks" do
    before do
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: lancer, target: p2)
      current_turn.attackers_declared!
    end

    it "creates a tapped and attacking 1/1 red Warrior" do
      expect(warriors.size).to eq(1)
      expect(warriors.first).to be_tapped
      expect([warriors.first.power, warriors.first.toughness]).to eq([1, 1])
      expect(warriors.first.colors).to eq([:red])
      expect(current_turn.attacks.find { _1.attacker == warriors.first }.target).to eq(p2)
    end

    it "sacrifices the Warrior at the beginning of the next end step" do
      go_to_combat_damage!
      expect(p2.life).to eq(16)
      current_turn.end!
      game.settle!
      expect(warriors).to be_empty
    end
  end
end
