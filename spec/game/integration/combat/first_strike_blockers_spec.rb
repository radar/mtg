# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- first strike and double strike damage steps" do
  include_context "two player game"

  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Balduvian Bears", owner: p2) }

  def attack_and_block(attacker, *blockers)
    skip_to_combat!
    game.tick!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    blockers.each { current_turn.declare_blocker(_1, attacker: attacker) }
    go_to_combat_damage!
  end

  it "a first-strike blocker kills the attacker before it deals damage" do
    blocker.grant_keyword(Magic::Keywords::FIRST_STRIKE)

    attack_and_block(attacker, blocker)

    expect(attacker.zone).to be_nil
    expect(blocker.zone).to be_battlefield
    expect(blocker.damage).to eq(0)
  end

  it "a first-strike attacker kills the blocker before it deals damage" do
    attacker.grant_keyword(Magic::Keywords::FIRST_STRIKE)

    attack_and_block(attacker, blocker)

    expect(blocker.zone).to be_nil
    expect(attacker.zone).to be_battlefield
    expect(attacker.damage).to eq(0)
  end

  it "creatures that both have first strike trade in the first-strike step" do
    attacker.grant_keyword(Magic::Keywords::FIRST_STRIKE)
    blocker.grant_keyword(Magic::Keywords::FIRST_STRIKE)

    attack_and_block(attacker, blocker)

    expect(attacker.zone).to be_nil
    expect(blocker.zone).to be_nil
  end

  it "a double-strike blocker deals damage in both steps" do
    big_attacker = ResolvePermanent("Vastwood Gorger", owner: p1)
    blocker.grant_keyword(Magic::Keywords::DOUBLE_STRIKE)

    attack_and_block(big_attacker, blocker)

    expect(big_attacker.damage).to eq(4)
    expect(blocker.zone).to be_nil
  end

  it "an attacker whose only blocker died in the first-strike step stays blocked and deals no damage" do
    attacker.grant_keyword(Magic::Keywords::DOUBLE_STRIKE)

    expect { attack_and_block(attacker, blocker) }.not_to change { p2.life }
    expect(blocker.zone).to be_nil
  end

  it "a double-strike trampler deals all its regular damage to the player once its blocker has died" do
    attacker.grant_keyword(Magic::Keywords::DOUBLE_STRIKE)
    attacker.grant_keyword(Magic::Keywords::TRAMPLE)

    expect { attack_and_block(attacker, blocker) }.to change { p2.life }.by(-2)
  end
end
