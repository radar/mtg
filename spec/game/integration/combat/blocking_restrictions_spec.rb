# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- blocking restrictions" do
  include_context "two player game"

  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Balduvian Bears", owner: p2) }

  def attack_with(*attackers)
    skip_to_combat!
    game.tick!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
  end

  context "flying" do
    before { attacker.grant_keyword(Magic::Keywords::FLYING) }

    it "can't be blocked by a creature without flying or reach" do
      attack_with(attacker)

      expect(current_turn.can_block?(attacker: attacker, blocker: blocker)).to eq(false)
      expect { current_turn.declare_blocker(blocker, attacker: attacker) }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /flying/)
    end

    it "can be blocked by a creature with reach" do
      blocker.grant_keyword(Magic::Keywords::REACH)
      attack_with(attacker)

      expect { current_turn.declare_blocker(blocker, attacker: attacker) }.not_to raise_error
    end

    it "can be blocked by a creature with flying" do
      blocker.grant_keyword(Magic::Keywords::FLYING)
      attack_with(attacker)

      expect { current_turn.declare_blocker(blocker, attacker: attacker) }.not_to raise_error
    end
  end

  context "a blocker with flying" do
    it "can block a creature without flying" do
      blocker.grant_keyword(Magic::Keywords::FLYING)
      attack_with(attacker)

      expect { current_turn.declare_blocker(blocker, attacker: attacker) }.not_to raise_error
    end
  end

  context "menace" do
    let!(:second_blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { attacker.grant_keyword(Magic::Keywords::MENACE) }

    it "can't be blocked by just one creature" do
      attack_with(attacker)
      current_turn.declare_blocker(blocker, attacker: attacker)

      expect { current_turn.combat_damage! }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /menace/)
      expect(current_turn.step).to eq("declare_blockers")
    end

    it "can be blocked by two creatures" do
      attack_with(attacker)
      current_turn.declare_blocker(blocker, attacker: attacker)
      current_turn.declare_blocker(second_blocker, attacker: attacker)

      go_to_combat_damage!

      expect(attacker).to be_dead
    end

    it "can go unblocked" do
      attack_with(attacker)

      expect { go_to_combat_damage! }.to change { p2.life }.by(-2)
    end
  end

  context "skulk" do
    before { attacker.grant_keyword(Magic::Keywords::SKULK) }

    it "can't be blocked by a creature with greater power" do
      big_blocker = ResolvePermanent("Vastwood Gorger", owner: p2)
      attack_with(attacker)

      expect { current_turn.declare_blocker(big_blocker, attacker: attacker) }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /skulk/)
    end

    it "can be blocked by a creature with equal power" do
      attack_with(attacker)

      expect { current_turn.declare_blocker(blocker, attacker: attacker) }.not_to raise_error
    end
  end

  it "doesn't let a tapped creature block" do
    blocker.tap!
    attack_with(attacker)

    expect { current_turn.declare_blocker(blocker, attacker: attacker) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /tapped/)
  end

  it "doesn't let the attacking player's creatures block" do
    own_creature = ResolvePermanent("Balduvian Bears", owner: p1)
    attack_with(attacker)

    expect { current_turn.declare_blocker(own_creature, attacker: attacker) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /defending player/)
  end

  it "doesn't let one creature block two attackers" do
    second_attacker = ResolvePermanent("Onakke Ogre", owner: p1)
    attack_with(attacker, second_attacker)
    current_turn.declare_blocker(blocker, attacker: attacker)

    expect { current_turn.declare_blocker(blocker, attacker: second_attacker) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /already blocking/)
  end

  it "doesn't let a creature block something that isn't attacking" do
    bystander = ResolvePermanent("Onakke Ogre", owner: p1)
    attack_with(attacker)

    expect { current_turn.declare_blocker(blocker, attacker: bystander) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /isn't attacking/)
  end
end
