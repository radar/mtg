# frozen_string_literal: true

require "spec_helper"

RSpec.describe "action legality" do
  include_context "two player game"

  describe "casting" do
    it "raises for a sorcery-speed spell during combat, but still allows an instant" do
      bears = Card("Grizzly Bears", owner: p1)
      shock = Card("Shock", owner: p1)
      p1.hand.add(bears)
      p1.hand.add(shock)
      p1.add_mana(green: 2, red: 1)

      go_to_main_phase!
      current_turn.beginning_of_combat!

      expect do
        p1.cast(card: bears) do |action|
          action.pay_mana(generic: { green: 1 }, green: 1)
        end
      end.to raise_error(Magic::IllegalAction, /sorcery speed/)

      expect do
        p1.cast(card: shock) do |action|
          action.pay_mana(red: 1)
          action.targeting(p2)
        end
      end.not_to raise_error
    end

    it "raises when the spell cannot be paid for" do
      go_to_main_phase!
      p1.hand.add(Card("Grizzly Bears", owner: p1))

      expect do
        p1.cast(card: p1.hand.by_name("Grizzly Bears").first)
      end.to raise_error(Magic::IllegalAction, /cannot pay/)
    end

    it "raises when the card is in the wrong zone" do
      go_to_main_phase!
      shock = Card("Shock", owner: p1)
      p1.graveyard.add(shock)
      p1.add_mana(red: 1)

      expect do
        p1.cast(card: shock) do |action|
          action.pay_mana(red: 1)
          action.targeting(p2)
        end
      end.to raise_error(Magic::IllegalAction, /zone it can be cast from/)
    end

    it "enforces spell cast limits" do
      go_to_main_phase!
      shock_1 = Card("Shock", owner: p1)
      shock_2 = Card("Shock", owner: p1)
      p1.hand.add(shock_1)
      p1.hand.add(shock_2)
      p1.add_mana(red: 2)
      p1.limit_spells_this_turn!(1)

      p1.cast(card: shock_1) do |action|
        action.pay_mana(red: 1)
        action.targeting(p2)
      end

      expect do
        p1.cast(card: shock_2) do |action|
          action.pay_mana(red: 1)
          action.targeting(p2)
        end
      end.to raise_error(Magic::IllegalAction, /cannot cast any more spells/)
    end
  end

  describe "playing lands" do
    it "raises on a second land play in the same turn" do
      go_to_main_phase!
      island = Card("Island", owner: p1)
      forest = Card("Forest", owner: p1)
      p1.hand.add(island)
      p1.hand.add(forest)

      p1.play_land(land: island)

      expect do
        p1.play_land(land: forest)
      end.to raise_error(Magic::IllegalAction, /maximum number of lands/)
    end
  end

  describe "activated abilities with tap costs" do
    it "raises while the source has summoning sickness, then works on a later turn" do
      speaker = ResolvePermanent("Speaker Of The Heavens", owner: p1)
      p1.gain_life(7)

      expect do
        p1.activate_ability(ability: speaker.activated_abilities.first)
      end.to raise_error(Magic::IllegalAction)

      2.times { game.next_turn }
      go_to_main_phase!

      expect do
        p1.activate_ability(ability: speaker.activated_abilities.first)
      end.not_to raise_error
    end
  end

  describe "loyalty abilities" do
    it "raises on a second activation in the same turn" do
      planeswalker = ResolvePermanent("Ob Nixilis Reignited", owner: p1)

      go_to_main_phase!
      p1.activate_loyalty_ability(ability: planeswalker.loyalty_abilities.first)

      expect do
        p1.activate_loyalty_ability(ability: planeswalker.loyalty_abilities.first)
      end.to raise_error(Magic::IllegalAction, /already activated/)
    end
  end

  describe "attacking" do
    it "raises for a summoning-sick attacker, but allows haste" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      goblin = ResolvePermanent("Raging Goblin", owner: p1)

      skip_to_combat!

      expect do
        p1.declare_attacker(attacker: bears, target: p2)
      end.to raise_error(Magic::IllegalAction, /summoning sickness/)

      expect do
        p1.declare_attacker(attacker: goblin, target: p2)
      end.not_to raise_error
    end
  end
end
