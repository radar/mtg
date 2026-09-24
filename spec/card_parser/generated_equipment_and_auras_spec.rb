# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated Equipment and Aura buffs in play" do
  include CardParserHelpers
  include_context "two player game"

  context "with generated Equipment" do
    let!(:sword) do
      load_card("Parsed Blade {2}\nArtifact — Equipment\nEquipped creature gets +2/+1 and has first strike.\nEquip {1}\n")
      ResolvePermanent("Parsed Blade", owner: p1)
    end
    let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def equip(creature)
      p1.add_mana(white: 1)
      p1.activate_ability(ability: sword.activated_abilities.first) do
        _1.targeting(creature)
        _1.pay_mana(generic: { white: 1 })
      end
      game.stack.resolve!
      game.tick!
    end

    it "buffs only the equipped creature" do
      equip(elves)
      expect([elves.power, elves.toughness, elves.first_strike?]).to eq([3, 2, true])
      expect([bears.power, bears.first_strike?]).to eq([2, false])
    end

    it "moves the buff when equipped to another creature" do
      equip(elves)
      equip(bears)
      expect([elves.power, elves.first_strike?]).to eq([1, false])
      expect([bears.power, bears.toughness, bears.first_strike?]).to eq([4, 3, true])
    end
  end

  context "with a generated Aura" do
    before do
      load_card("Parsed Wings {1}{U}\nEnchantment — Aura\nEnchant creature\nEnchanted creature gets +1/+1 and has flying.\n")
      go_to_main_phase!
    end

    it "buffs only the enchanted creature, and stops when it leaves" do
      elves = ResolvePermanent("Wood Elves", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      wings = Card("Parsed Wings", owner: p1)
      p1.hand.add(wings)
      p1.add_mana(blue: 2)
      p1.cast(card: wings) do
        _1.pay_mana(generic: { blue: 1 }, blue: 1)
        _1.targeting(elves)
      end
      game.stack.resolve!
      game.tick!

      expect([elves.power, elves.toughness, elves.flying?]).to eq([2, 2, true])
      expect([bears.power, bears.flying?]).to eq([2, false])

      p1.permanents.by_name("Parsed Wings").first.destroy!
      game.tick!
      expect([elves.power, elves.flying?]).to eq([1, false])
    end
  end
end
