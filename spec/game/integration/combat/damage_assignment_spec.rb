# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- damage assignment" do
  include_context "two player game"

  let(:keywords) { Magic::Cards::Keywords }
  let(:invalid) { Magic::Game::CombatPhase::InvalidDamageAssignment }

  def attack_with(attacker, *blockers)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    blockers.each { |blocker| current_turn.declare_blocker(blocker, attacker: attacker) }
  end

  describe "default assignment" do
    it "assigns lethal damage to each blocker in turn, and the rest to the last" do
      gorger = ResolvePermanent("Vastwood Gorger", owner: p1)
      elves = ResolvePermanent("Wood Elves", owner: p2)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)

      attack_with(gorger, elves, bears)
      go_to_combat_damage!

      expect(elves).to be_dead
      expect(bears).to be_dead
      expect(p2.life).to eq(20)
    end

    it "accounts for damage already marked on a blocker" do
      dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p1)
      gorger = ResolvePermanent("Vastwood Gorger", owner: p2)
      gorger.take_damage(4)

      attack_with(dreadmaw, gorger)
      go_to_combat_damage!

      # Only 2 more damage is lethal to the 5/6, so 4 of the Dreadmaw's 6 trample over.
      expect(gorger).to be_dead
      expect(p2.life).to eq(16)
    end

    it "treats 1 damage from a deathtouch attacker as lethal for every blocker" do
      gorger = ResolvePermanent("Vastwood Gorger", owner: p1)
      gorger.grant_keyword(keywords::DEATHTOUCH)
      first = ResolvePermanent("Vastwood Gorger", owner: p2)
      second = ResolvePermanent("Vastwood Gorger", owner: p2)
      third = ResolvePermanent("Vastwood Gorger", owner: p2)

      attack_with(gorger, first, second, third)
      go_to_combat_damage!

      expect([first, second, third]).to all(be_dead)
    end

    it "assigns all damage to a lone blocker even beyond lethal" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      gorger = ResolvePermanent("Vastwood Gorger", owner: p2)

      attack_with(bears, gorger)
      go_to_combat_damage!

      expect(gorger.damage).to eq(2)
    end
  end

  describe "an attacker whose blockers all left combat" do
    it "stays blocked and deals no damage without trample" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      elves = ResolvePermanent("Wood Elves", owner: p2)

      attack_with(bears, elves)
      elves.destroy!
      game.settle!
      go_to_combat_damage!

      expect(p2.life).to eq(20)
    end

    it "assigns all its damage to the defending player with trample" do
      dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p1)
      elves = ResolvePermanent("Wood Elves", owner: p2)

      attack_with(dreadmaw, elves)
      elves.destroy!
      game.settle!
      go_to_combat_damage!

      expect(p2.life).to eq(14)
    end
  end

  describe "choosing the assignment" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:gorger) { ResolvePermanent("Vastwood Gorger", owner: p2) }
    let!(:elves) { ResolvePermanent("Wood Elves", owner: p2) }

    before { attack_with(bears, gorger, elves) }

    it "uses the attacking player's split" do
      current_turn.combat.assign_combat_damage(bears, gorger => 1, elves => 1)
      go_to_combat_damage!

      expect(elves).to be_dead
      expect(gorger.damage).to eq(1)
    end

    it "rejects a split that leaves damage unassigned" do
      expect { current_turn.combat.assign_combat_damage(bears, gorger => 1, elves => 0) }
        .to raise_error(invalid, /all combat damage must be assigned/)
    end

    it "rejects a split that assigns more damage than the attacker has" do
      expect { current_turn.combat.assign_combat_damage(bears, gorger => 2, elves => 2) }
        .to raise_error(invalid, /more than 2/)
    end

    it "rejects a split that leaves out a blocker" do
      expect { current_turn.combat.assign_combat_damage(bears, gorger => 2) }
        .to raise_error(invalid, /among the blockers/)
    end
  end

  describe "choosing the assignment with trample" do
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
    let!(:elves) { ResolvePermanent("Wood Elves", owner: p2) }

    before { attack_with(dreadmaw, elves) }

    it "requires lethal damage to each blocker before trampling over" do
      expect { current_turn.combat.assign_combat_damage(dreadmaw, elves => 0) }
        .to raise_error(invalid, /lethal/)
    end

    it "tramples over whatever isn't assigned to the blockers" do
      current_turn.combat.assign_combat_damage(dreadmaw, elves => 2)
      go_to_combat_damage!

      expect(elves).to be_dead
      expect(p2.life).to eq(16)
    end
  end
end
