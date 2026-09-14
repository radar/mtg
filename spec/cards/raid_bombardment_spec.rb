# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaidBombardment do
  include_context "two player game"

  subject!(:bombardment) { ResolvePermanent("Raid Bombardment", owner: p1) }

  context "whenever a creature you control with power 2 or less attacks" do
    it "deals 1 damage to the player it's attacking" do
      goblin = ResolvePermanent("Grizzly Bears", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: goblin, target: p2)
      current_turn.attackers_declared!

      expect(p2.life).to eq(19)
    end
  end

  context "whenever a creature you control with power greater than 2 attacks" do
    it "does not deal damage" do
      beast = ResolvePermanent("Axebane Beast", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: beast, target: p2)
      current_turn.attackers_declared!

      expect(p2.life).to eq(20)
    end
  end

  context "whenever a creature an opponent controls with power 2 or less attacks" do
    it "does not deal damage" do
      goblin = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      p2.declare_attacker(attacker: goblin, target: p1)
      current_turn.attackers_declared!

      expect(p1.life).to eq(20)
    end
  end
end
