# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- dividing an attacker's damage among blockers" do
  include_context "two player game"

  let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
  let!(:first_bear) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:second_bear) { ResolvePermanent("Balduvian Bears", owner: p2) }

  def attack_and_block(*blockers)
    skip_to_combat!
    game.tick!
    current_turn.declare_attackers!
    current_turn.declare_attacker(dreadmaw, target: p2)
    current_turn.attackers_declared!
    blockers.each { current_turn.declare_blocker(_1, attacker: dreadmaw) }
  end

  it "assigns all of its damage to a single blocker" do
    gorger = ResolvePermanent("Vastwood Gorger", owner: p2)
    attack_and_block(gorger)

    go_to_combat_damage!

    expect(gorger.zone).to be_nil
  end

  it "counts damage already marked on a blocker toward lethal damage when trampling" do
    gorger = ResolvePermanent("Vastwood Gorger", owner: p2)
    gorger.take_damage(2)
    dreadmaw.grant_keyword(Magic::Keywords::TRAMPLE)
    attack_and_block(gorger)

    expect { go_to_combat_damage! }.to change { p2.life }.by(-2)
    expect(gorger.zone).to be_nil
  end

  it "with deathtouch, one damage is lethal to each blocker" do
    gorger = ResolvePermanent("Vastwood Gorger", owner: p2)
    dreadmaw.grant_keyword(Magic::Keywords::DEATHTOUCH)
    attack_and_block(gorger, first_bear, second_bear)

    go_to_combat_damage!

    expect([gorger, first_bear, second_bear].map(&:zone)).to all(be_nil)
  end

  context "when the attacking player divides the damage" do
    it "uses the division they choose" do
      attack_and_block(first_bear, second_bear)
      current_turn.assign_combat_damage(dreadmaw, { first_bear => 1, second_bear => 5 })

      go_to_combat_damage!

      expect(first_bear.zone).to be_battlefield
      expect(first_bear.damage).to eq(1)
      expect(second_bear.zone).to be_nil
    end

    it "lets a trampler send damage to the player once each blocker has lethal damage" do
      dreadmaw.grant_keyword(Magic::Keywords::TRAMPLE)
      attack_and_block(first_bear)
      current_turn.assign_combat_damage(dreadmaw, { first_bear => 3, p2 => 3 })

      expect { go_to_combat_damage! }.to change { p2.life }.by(-3)
    end

    it "doesn't let a trampler skip lethal damage to a blocker" do
      dreadmaw.grant_keyword(Magic::Keywords::TRAMPLE)
      attack_and_block(first_bear)

      expect { current_turn.assign_combat_damage(dreadmaw, { first_bear => 1, p2 => 5 }) }
        .to raise_error(Magic::Game::CombatPhase::IllegalDamageAssignment, /lethal/)
    end

    it "doesn't let a creature without trample assign damage to the player" do
      ogre = ResolvePermanent("Onakke Ogre", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(ogre, target: p2)
      current_turn.attackers_declared!
      current_turn.declare_blocker(first_bear, attacker: ogre)

      expect { current_turn.assign_combat_damage(ogre, { first_bear => 2, p2 => 2 }) }
        .to raise_error(Magic::Game::CombatPhase::IllegalDamageAssignment, /trample/)
    end

    it "must assign all of the attacker's damage" do
      attack_and_block(first_bear, second_bear)

      expect { current_turn.assign_combat_damage(dreadmaw, { first_bear => 2, second_bear => 2 }) }
        .to raise_error(Magic::Game::CombatPhase::IllegalDamageAssignment, /exactly 6/)
    end

    it "can only assign damage to creatures blocking it" do
      bystander = ResolvePermanent("Onakke Ogre", owner: p2)
      attack_and_block(first_bear)

      expect { current_turn.assign_combat_damage(dreadmaw, { first_bear => 2, bystander => 4 }) }
        .to raise_error(Magic::Game::CombatPhase::IllegalDamageAssignment, /isn't blocking/)
    end
  end

  it "a creature with no power deals no combat damage" do
    allow(dreadmaw).to receive(:power).and_return(0)
    attack_and_block(first_bear)

    go_to_combat_damage!

    expect(first_bear.damage).to eq(0)
    expect(game.current_turn.events.select { _1.is_a?(Magic::Events::CombatDamageDealt) && _1.source == dreadmaw }).to be_empty
  end
end
