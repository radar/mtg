# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrashTaunter do
  include_context "two player game"

  subject!(:taunter) { ResolvePermanent("Brash Taunter", owner: p1) }

  it "is a 1/1 Goblin" do
    expect(taunter.power).to eq(1)
    expect(taunter.toughness).to eq(1)
  end

  it "is indestructible" do
    expect(taunter.indestructible?).to eq(true)
  end

  context "whenever it is dealt damage" do
    it "deals that much damage to target opponent" do
      p2.add_mana(red: 1)
      p2.cast(card: Card("Shock", owner: p2)) { |a| a.pay_mana(red: 1).targeting(taunter) }

      game.stack.resolve!

      expect(p2.life).to eq(18)
    end

    it "fires from combat damage too" do
      bear = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bear, target: p1)
      current_turn.attackers_finalized!
      current_turn.declare_blocker(taunter, attacker: bear)
      go_to_combat_damage!

      expect(taunter.damage).to eq(1)
      expect(p2.life).to eq(19)
    end
  end

  context "activated ability: {2}{R}, {T}: fights another target creature" do
    let(:ability) { taunter.activated_abilities.first }

    it "deals damage to both creatures equal to their power, redirecting its own damage to an opponent" do
      bear = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(generic: 2, red: 1)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { generic: 2 }, red: 1)
        _1.targeting(bear)
      end

      game.stack.resolve!

      expect(bear.damage).to eq(1)
      expect(taunter.damage).to eq(2)
      expect(taunter.zone).not_to be_nil
      expect(p2.life).to eq(18)
    end
  end
end
