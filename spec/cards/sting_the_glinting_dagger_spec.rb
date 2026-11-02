# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StingTheGlintingDagger do
  include_context "two player game"

  let!(:sting) { ResolvePermanent("Sting The Glinting Dagger", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  before { go_to_main_phase! }

  def equip(creature)
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: sting.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
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
    game.settle!
    game.tick!
  end

  def p2_attacks_with(attacker, blocker)
    skip_to_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker: attacker, target: p1)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
    game.settle!
    game.tick!
  end

  it "is a legendary {2} Equipment with equip {2}" do
    expect(sting.legendary?).to be true
    expect(sting.card.mana_value).to eq(2)
    ability = sting.activated_abilities.first
    expect(ability.costs.size).to eq(1)
    expect(ability.costs.first.cost[:generic]).to eq(2)
  end

  it "can only be equipped at sorcery speed" do
    go_to_main_phase_for!(p2)
    p1.add_mana(colorless: 2)

    expect do
      p1.activate_ability(ability: sting.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 2 })
        a.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction, /requirements to activate/)
  end

  it "gives equipped creature +1/+1 and haste, and nobody else" do
    sick = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    game.tick!
    equip(sick)

    expect([sick.power, sick.toughness]).to eq([3, 3])
    expect(sick).to have_keyword(:haste)
    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to have_keyword(:haste)
  end

  it "loses the bonuses when Sting leaves the battlefield" do
    equip(bears)
    sting.destroy!
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to have_keyword(:haste)
  end

  describe "at the beginning of each combat" do
    it "untaps equipped creature on your turn" do
      equip(bears)
      bears.tap!
      current_turn.beginning_of_combat!
      game.settle!

      expect(bears.tapped?).to be false
    end

    it "untaps equipped creature on the opponent's turn too" do
      equip(bears)
      go_to_main_phase_for!(p2)
      bears.tap!
      current_turn.beginning_of_combat!
      game.settle!

      expect(bears.tapped?).to be false
    end

    it "leaves other tapped creatures and an unequipped state alone" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      equip(bears)
      other.tap!
      current_turn.beginning_of_combat!
      game.settle!

      expect(other.tapped?).to be true
    end

    it "does nothing while it equips nothing" do
      bears.tap!
      current_turn.beginning_of_combat!
      game.settle!

      expect(bears.tapped?).to be true
    end
  end

  describe "first strike while blocking or blocked by a Goblin or Orc" do
    let(:goblin) { ResolvePermanent("Goblin Arsonist", owner: p2) }
    let(:orc) { ResolvePermanent("Cirith Ungol Patrol", owner: p2) }
    let(:plain) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { equip(bears) }

    it "has no first strike outside combat" do
      expect(bears).not_to have_keyword(:first_strike)
    end

    it "has first strike when blocked by a Goblin" do
      p1_attacks_with(bears, goblin)

      expect(bears).to have_keyword(:first_strike)
    end

    it "has first strike when blocked by an Orc" do
      p1_attacks_with(bears, orc)

      expect(bears).to have_keyword(:first_strike)
    end

    it "has no first strike when blocked by a creature that is neither" do
      p1_attacks_with(bears, plain)

      expect(bears).not_to have_keyword(:first_strike)
    end

    it "has first strike when blocking an Orc" do
      orc_attacker = orc
      go_to_main_phase_for!(p2)
      p2_attacks_with(orc_attacker, bears)

      expect(bears).to have_keyword(:first_strike)
    end

    it "has no first strike when blocking a non-Goblin, non-Orc" do
      attacker = plain
      go_to_main_phase_for!(p2)
      p2_attacks_with(attacker, bears)

      expect(bears).not_to have_keyword(:first_strike)
    end

    it "does not give first strike to an unequipped creature blocked by an Orc" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      p1_attacks_with(other, orc)

      expect(other).not_to have_keyword(:first_strike)
    end
  end
end
