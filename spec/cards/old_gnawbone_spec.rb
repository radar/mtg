# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OldGnawbone do
  include_context "two player game"

  subject!(:gnawbone) { ResolvePermanent("Old Gnawbone", owner: p1) }

  it "has flying" do
    expect(gnawbone.flying?).to eq(true)
  end

  context "when it deals combat damage to a player" do
    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(gnawbone, target: p2)
      go_to_combat_damage!
    end

    it "creates that many Treasure tokens" do
      treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }
      expect(treasures.count).to eq(7)
    end
  end

  context "when another creature you control deals combat damage to a player" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      go_to_combat_damage!
    end

    it "creates that many Treasure tokens" do
      treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }
      expect(treasures.count).to eq(2)
    end
  end

  context "when a creature an opponent controls deals combat damage to a player" do
    let!(:opponents_creature) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(opponents_creature, target: p1)
      go_to_combat_damage!
    end

    it "does not create Treasure tokens for its controller" do
      treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }
      expect(treasures.count).to eq(0)
    end
  end

  context "when a creature you control deals combat damage to a blocking creature, not a player" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.attackers_finalized!
      current_turn.declare_blocker(blocker, attacker: bears)
      go_to_combat_damage!
    end

    it "does not create Treasure tokens" do
      treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }
      expect(treasures.count).to eq(0)
    end
  end
end
