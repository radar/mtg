# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BillThePony do
  include_context "two player game"

  def foods = p1.permanents.select { _1.type?("Food") }

  def attack_unblocked!(attacker)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!
  end

  it "is a legendary 1/4 Horse" do
    card = Card("Bill The Pony")
    expect([card.base_power, card.base_toughness]).to eq([1, 4])
    expect(card.type?("Horse")).to be(true)
    expect(card.type?("Legendary")).to be(true)
  end

  it "creates two Food tokens when it enters, only for its controller" do
    ResolvePermanent("Bill The Pony", owner: p1)
    game.settle!

    expect(foods.count).to eq(2)
    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end

  context "sacrifice ability" do
    before { go_to_main_phase! }

    let!(:bill) { ResolvePermanent("Bill The Pony", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let(:ability) { bill.activated_abilities.first }

    def activate(food, target)
      p1.activate_ability(ability: ability) do |a|
        a.pay_sacrifice(food)
        a.targeting(target)
      end
      game.stack.resolve!
      game.settle!
    end

    it "makes the target assign combat damage equal to its toughness this turn" do
      game.settle!
      food = foods.first
      activate(food, bill)
      expect(foods.count).to eq(1)
      expect(food.zone).to be_nil

      attack_unblocked!(bill)

      expect(p2.life).to eq(16)
    end

    it "does nothing to creatures that were not targeted" do
      game.settle!
      activate(foods.first, bill)
      bears.modify_toughness(2)
      game.tick!
      expect([bears.power, bears.toughness]).to eq([2, 4])

      attack_unblocked!(bears)

      # Deals its power (2), not its toughness (4).
      expect(p2.life).to eq(18)
    end

    it "wears off at end of turn" do
      game.settle!
      activate(foods.first, bill)
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(bill.assigns_toughness_damage?).to be(false)
      expect(bill.combat_damage_amount).to eq(1)
    end

    it "requires a Food to sacrifice" do
      game.settle!
      cost = ability.costs.find { _1.is_a?(Magic::Costs::Sacrifice) }
      expect(cost.choices).to match_array(foods)
      expect(cost.choices).not_to include(bears)
    end

    it "can only target creatures its controller controls" do
      game.settle!
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)

      expect(ability.target_choices).to include(bill, bears)
      expect(ability.target_choices).not_to include(theirs)
    end
  end
end
