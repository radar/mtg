# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BarrowBlade do
  include_context "two player game"

  let!(:blade) { ResolvePermanent("Barrow-Blade", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:jazal) { ResolvePermanent("Jazal Goldmane", owner: p2) } # 4/4 first strike
  before { go_to_main_phase! }

  def equip(creature)
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: blade.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 1 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  def p1_attacks_with(attacker, blocker)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
  end

  it "is a {1} Equipment with equip {1}" do
    expect(blade.card.mana_value).to eq(1)
    ability = blade.activated_abilities.first
    expect(ability.costs.size).to eq(1)
    expect(ability.costs.first.cost[:generic]).to eq(1)
  end

  it "can only be equipped at sorcery speed" do
    go_to_main_phase_for!(p2)
    p1.add_mana(colorless: 1)

    expect do
      p1.activate_ability(ability: blade.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 1 })
        a.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction, /requirements to activate/)
  end

  it "gives equipped creature +1/+1 only" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    equip(bears)

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([other.power, other.toughness]).to eq([2, 2])
  end

  it "removes the bonus when the Blade leaves the battlefield" do
    equip(bears)
    blade.destroy!
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  describe "when equipped creature becomes blocked" do
    before { equip(bears) }

    it "makes the blocker lose all abilities" do
      expect(jazal).to have_keyword(:first_strike)
      p1_attacks_with(bears, jazal)
      game.settle!
      game.tick!

      expect(jazal).not_to have_keyword(:first_strike)
      expect(jazal.lost_all_abilities?).to be true
    end

    it "restores the blocker's abilities after cleanup" do
      p1_attacks_with(bears, jazal)
      game.settle!
      game.tick!
      expect(jazal).not_to have_keyword(:first_strike)

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(jazal.lost_all_abilities?).to be false
      expect(jazal).to have_keyword(:first_strike)
    end

    it "does not affect the equipped creature itself" do
      p1_attacks_with(bears, jazal)
      game.settle!

      expect(bears.lost_all_abilities?).to be false
    end

    it "still resolves if the Blade leaves the battlefield first" do
      p1_attacks_with(bears, jazal)
      blade.destroy!
      game.settle!
      game.tick!

      expect(jazal.lost_all_abilities?).to be true
    end
  end

  describe "when equipped creature blocks" do
    it "makes the attacking creature lose all abilities" do
      equip(bears)
      go_to_main_phase_for!(p2)
      skip_to_combat!
      current_turn.declare_attackers!
      p2.declare_attacker(attacker: jazal, target: p1)
      current_turn.attackers_declared!
      current_turn.declare_blocker(bears, attacker: jazal)
      game.settle!
      game.tick!

      expect(jazal).not_to have_keyword(:first_strike)
      expect(bears.lost_all_abilities?).to be false

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(jazal).to have_keyword(:first_strike)
    end
  end

  describe "when an unequipped creature is blocked" do
    it "does not trigger" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      equip(bears)
      p1_attacks_with(other, jazal)
      game.settle!
      game.tick!

      expect(game.choices).to be_empty
      expect(jazal.lost_all_abilities?).to be false
      expect(jazal).to have_keyword(:first_strike)
    end
  end
end
