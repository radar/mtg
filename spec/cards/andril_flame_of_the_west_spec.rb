# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AndrilFlameOfTheWest do
  include_context "two player game"

  let!(:andril) { ResolvePermanent("Andril Flame Of The West", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:jazal) { ResolvePermanent("Jazal Goldmane", owner: p1) } # legendary 4/4
  before { go_to_main_phase! }

  def equip(creature)
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: andril.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def spirits = p1.creatures.select { _1.token? && _1.type?("Spirit") }

  it "is a legendary {3} Equipment with equip {2}" do
    expect(andril.card).to be_a(Magic::Cards::Equipment)
    expect(andril.legendary?).to be true
    expect(andril.card.mana_value).to eq(3)
    ability = andril.activated_abilities.first
    expect(ability.costs.size).to eq(1)
    expect(ability.costs.first.cost[:generic]).to eq(2)
  end

  it "can only be equipped at sorcery speed" do
    go_to_main_phase_for!(p2)
    p1.add_mana(colorless: 2)

    expect do
      p1.activate_ability(ability: andril.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 2 })
        a.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction, /requirements to activate/)
  end

  it "gives equipped creature +3/+1 and nobody else" do
    equip(bears)

    expect([bears.power, bears.toughness]).to eq([5, 3])
    expect([jazal.power, jazal.toughness]).to eq([4, 4])
  end

  it "loses the bonus when Andúril leaves the battlefield" do
    equip(bears)
    andril.destroy!
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  describe "when equipped creature attacks" do
    it "creates two tapped, non-attacking 1/1 white flying Spirits for a nonlegendary creature" do
      equip(bears)
      attack_with(bears)

      expect(spirits.size).to eq(2)
      expect(spirits).to all(be_tapped)
      expect(spirits).to all(have_keyword(:flying))
      expect([spirits.first.power, spirits.first.toughness]).to eq([1, 1])
      expect(spirits.map { current_turn.combat.attacking?(_1) }).to eq([false, false])
    end

    it "creates two tapped and attacking Spirits for a legendary creature" do
      equip(jazal)
      attack_with(jazal)

      expect(spirits.size).to eq(2)
      expect(spirits).to all(be_tapped)
      expect(spirits.map { current_turn.combat.attacking?(_1) }).to eq([true, true])
    end

    it "does not trigger for an unequipped attacker" do
      equip(bears)
      attack_with(jazal)

      expect(spirits).to be_empty
      expect(game.choices).to be_empty
    end

    it "still creates the tokens if the Equipment leaves before the trigger resolves" do
      equip(jazal)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: jazal, target: p2)
      current_turn.attackers_declared!
      andril.destroy!
      game.settle!

      expect(spirits.size).to eq(2)
      expect(spirits.map { current_turn.combat.attacking?(_1) }).to eq([true, true])
    end
  end
end
