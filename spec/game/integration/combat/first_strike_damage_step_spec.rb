# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- first strike and double strike damage steps" do
  include_context "two player game"

  let(:keywords) { Magic::Cards::Keywords }
  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def block_and_deal_damage!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
    go_to_combat_damage!
  end

  it "a first-strike blocker kills a non-first-strike attacker before it deals damage" do
    blocker.grant_keyword(keywords::FIRST_STRIKE)

    block_and_deal_damage!

    expect(attacker).to be_dead
    expect(blocker).not_to be_dead
    expect(blocker.damage).to eq(0)
  end

  it "a first-strike attacker kills a non-first-strike blocker before it deals damage" do
    attacker.grant_keyword(keywords::FIRST_STRIKE)

    block_and_deal_damage!

    expect(blocker).to be_dead
    expect(attacker).not_to be_dead
    expect(attacker.damage).to eq(0)
  end

  it "two first strikers deal damage to each other at the same time" do
    attacker.grant_keyword(keywords::FIRST_STRIKE)
    blocker.grant_keyword(keywords::FIRST_STRIKE)

    block_and_deal_damage!

    expect(attacker).to be_dead
    expect(blocker).to be_dead
  end

  it "a first-strike creature doesn't deal damage a second time in the regular step" do
    attacker.grant_keyword(keywords::FIRST_STRIKE)
    big_blocker = ResolvePermanent("Vastwood Gorger", owner: p2)

    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(big_blocker, attacker: attacker)
    go_to_combat_damage!

    expect(big_blocker.damage).to eq(2)
    expect(attacker).to be_dead
  end

  describe "double strike" do
    it "deals damage in both steps, and is dealt damage in the regular step only" do
      attacker.grant_keyword(keywords::DOUBLE_STRIKE)
      big_blocker = ResolvePermanent("Vastwood Gorger", owner: p2)

      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p2)
      current_turn.attackers_declared!
      current_turn.declare_blocker(big_blocker, attacker: attacker)
      go_to_combat_damage!

      expect(big_blocker.damage).to eq(4)
      expect(attacker).to be_dead
    end

    it "an unblocked double striker deals damage twice" do
      attacker.grant_keyword(keywords::DOUBLE_STRIKE)

      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p2)
      current_turn.attackers_declared!
      go_to_combat_damage!

      expect(p2.life).to eq(16)
    end

    it "a double-strike attacker that kills its blocker in the first step doesn't take damage" do
      attacker.grant_keyword(keywords::DOUBLE_STRIKE)

      block_and_deal_damage!

      expect(blocker).to be_dead
      expect(attacker.damage).to eq(0)
    end
  end

  describe "lifelink" do
    it "applies per damage event, so a first-strike lifelinker gains life before the regular step" do
      attacker.grant_keyword(keywords::FIRST_STRIKE)
      attacker.grant_keyword(keywords::LIFELINK)

      block_and_deal_damage!

      expect(p1.life).to eq(22)
    end

    it "a lifelink blocker gains life for the damage it deals" do
      blocker.grant_keyword(keywords::LIFELINK)

      block_and_deal_damage!

      expect(p2.life).to eq(22)
    end
  end
end
