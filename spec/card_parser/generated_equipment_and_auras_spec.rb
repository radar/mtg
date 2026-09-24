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

  context "with buffs that count" do
    it "gives the equipped creature +1/+1 for each Equipment you control" do
      load_card("Parsed Stack Blade {1}\nArtifact — Equipment\nEquipped creature gets +1/+1 for each Equipment you control.\nEquip {1}\n")
      blade = ResolvePermanent("Parsed Stack Blade", owner: p1)
      elves = ResolvePermanent("Wood Elves", owner: p1)
      p1.add_mana(white: 1)
      p1.activate_ability(ability: blade.activated_abilities.first) do
        _1.targeting(elves)
        _1.pay_mana(generic: { white: 1 })
      end
      game.stack.resolve!
      game.tick!
      expect([elves.power, elves.toughness]).to eq([2, 2])

      ResolvePermanent("Short Sword", owner: p1)
      ResolvePermanent("Short Sword", owner: p2)
      game.tick!
      expect([elves.power, elves.toughness]).to eq([3, 3])
    end

    it "grows with your other Elves, and shrinks when one leaves" do
      load_card("Parsed Chanter {1}{G}\nCreature — Elf\nParsed Chanter gets +1/+1 for each other Elf you control.\n1/1\n")
      chanter = ResolvePermanent("Parsed Chanter", owner: p1)
      game.tick!
      expect(chanter.power).to eq(1)

      elves = ResolvePermanent("Wood Elves", owner: p1)
      ResolvePermanent("Llanowar Elves", owner: p1)
      ResolvePermanent("Llanowar Elves", owner: p2)
      game.tick!
      expect([chanter.power, chanter.toughness]).to eq([3, 3])

      elves.destroy!
      game.tick!
      expect(chanter.power).to eq(2)
    end

    it "counts creature cards in your graveyard" do
      load_card("Parsed Grave Might {B}\nEnchantment — Aura\nEnchant creature\nEnchanted creature gets +1/+0 for each creature card in your graveyard.\n")
      go_to_main_phase!
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.graveyard.add(Card("Wood Elves", owner: p1))
      p1.graveyard.add(Card("Llanowar Elves", owner: p1))
      p1.graveyard.add(Card("Forest", owner: p1))
      might = Card("Parsed Grave Might", owner: p1)
      p1.hand.add(might)
      p1.add_mana(black: 1)
      p1.cast(card: might) { _1.pay_mana(black: 1).targeting(bears) }
      game.stack.resolve!
      game.tick!

      expect([bears.power, bears.toughness]).to eq([4, 2])
    end
  end
end
