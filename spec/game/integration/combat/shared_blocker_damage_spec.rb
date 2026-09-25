# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- lethal damage counts damage other creatures assign in the same step" do
  include_context "two player game"

  def allow_to_block(blocker, count)
    allow(blocker.card).to receive(:maximum_attackers_blocked).and_return(count)
  end

  def attack_with(*attackers)
    skip_to_combat!
    game.tick!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
  end

  context "a creature that can block two attackers" do
    let!(:first_bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:second_bear) { ResolvePermanent("Balduvian Bears", owner: p1) }
    let!(:third_bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:beast) { ResolvePermanent("Axebane Beast", owner: p2) }

    before do
      allow_to_block(beast, 2)
      attack_with(first_bear, second_bear, third_bear)
    end

    it "blocks two attackers, but not a third" do
      current_turn.declare_blocker(beast, attacker: first_bear)
      current_turn.declare_blocker(beast, attacker: second_bear)

      expect { current_turn.declare_blocker(beast, attacker: third_bear) }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /already blocking/)
    end

    it "can't block the same attacker twice" do
      current_turn.declare_blocker(beast, attacker: first_bear)

      expect { current_turn.declare_blocker(beast, attacker: first_bear) }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /already blocking Grizzly Bears/)
    end

    it "divides its damage between them, lethal damage first" do
      current_turn.declare_blocker(beast, attacker: first_bear)
      current_turn.declare_blocker(beast, attacker: second_bear)

      go_to_combat_damage!

      expect(first_bear.zone).to be_nil
      expect(second_bear.zone).to be_battlefield
      expect(second_bear.damage).to eq(1)
    end

    it "counts damage another blocker is dealing to an attacker" do
      jhovall = ResolvePermanent("Wild Jhovall", owner: p2)
      current_turn.declare_blocker(jhovall, attacker: first_bear)
      current_turn.declare_blocker(beast, attacker: first_bear)
      current_turn.declare_blocker(beast, attacker: second_bear)

      go_to_combat_damage!

      expect(first_bear.zone).to be_nil
      expect(second_bear.zone).to be_nil
    end
  end

  context "two tramplers blocked by the same creature" do
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:gorger) { ResolvePermanent("Vastwood Gorger", owner: p2) }

    before do
      bear.grant_keyword(Magic::Keywords::TRAMPLE)
      allow_to_block(gorger, 2)
      attack_with(dreadmaw, bear)
      current_turn.declare_blocker(gorger, attacker: dreadmaw)
      current_turn.declare_blocker(gorger, attacker: bear)
    end

    it "tramples over once the other attacker's damage is already lethal" do
      expect { go_to_combat_damage! }.to change { p2.life }.by(-2)
      expect(gorger.zone).to be_nil
    end

    it "lets a chosen division count the other attacker's chosen damage toward lethal" do
      current_turn.assign_combat_damage(bear, { gorger => 2 })
      current_turn.assign_combat_damage(dreadmaw, { gorger => 4, p2 => 2 })

      expect { go_to_combat_damage! }.to change { p2.life }.by(-2)
      expect(gorger.zone).to be_nil
    end

    it "doesn't count damage the other attacker hasn't been assigned" do
      expect { current_turn.assign_combat_damage(dreadmaw, { gorger => 4, p2 => 2 }) }
        .to raise_error(Magic::Game::CombatPhase::IllegalDamageAssignment, /lethal/)
    end
  end
end
