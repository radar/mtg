# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoilingVortex do
  include_context "two player game"

  let(:card) { Card("Roiling Vortex") }

  it "is an enchantment costing {1}{R}" do
    expect(card.enchantment?).to eq(true)
    expect(card.cost.mana_value).to eq(2)
    expect(card.cost.red).to eq(1)
  end

  describe "upkeep damage" do
    it "deals 1 damage to the active player at the beginning of their own upkeep" do
      ResolvePermanent("Roiling Vortex", owner: p1)

      expect { go_to_main_phase! }.to change { p1.life }.by(-1)
    end

    it "also deals 1 damage to the other player at the beginning of their upkeep" do
      ResolvePermanent("Roiling Vortex", owner: p1)
      go_to_main_phase!

      game.next_turn

      expect { go_to_main_phase! }.to change { p2.life }.by(-1)
    end
  end

  describe "casting a spell with no mana spent" do
    let!(:vortex) { ResolvePermanent("Roiling Vortex", owner: p1) }
    let(:bolt) { Card("Lightning Bolt", owner: p2) }

    it "deals 5 damage to the caster when no mana was spent" do
      action = cast_action(card: bolt, player: p2)
      action.mana_cost = {}
      action.targeting(p1)

      expect { game.take_action(action) }.to change { p2.life }.by(-5)
    end

    it "does not deal damage when mana was spent normally" do
      p2.add_mana(red: 1)
      action = cast_action(card: bolt, player: p2)
      action.pay_mana(red: 1)
      action.targeting(p1)

      expect { game.take_action(action) }.not_to change { p2.life }
    end
  end

  describe "activated ability" do
    let!(:vortex) { ResolvePermanent("Roiling Vortex", owner: p1) }

    it "prevents opponents from gaining life this turn once activated" do
      p1.add_mana(red: 1)
      ability = vortex.activated_abilities.first
      p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!

      effect = Magic::Effects::GainLife.new(source: p1, target: p2, life: 3)
      expect { game.add_effect(effect) }.not_to change { p2.life }
    end

    it "does not prevent the controller from gaining life" do
      p1.add_mana(red: 1)
      ability = vortex.activated_abilities.first
      p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!

      effect = Magic::Effects::GainLife.new(source: p1, target: p1, life: 3)
      expect { game.add_effect(effect) }.to change { p1.life }.by(3)
    end

    it "no longer prevents life gain on a later turn" do
      p1.add_mana(red: 1)
      ability = vortex.activated_abilities.first
      p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!

      game.next_turn
      game.next_turn

      effect = Magic::Effects::GainLife.new(source: p1, target: p2, life: 3)
      expect { game.add_effect(effect) }.to change { p2.life }.by(3)
    end
  end
end
