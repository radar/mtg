# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArenaOfGlory do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "enters tapped unless you control a Mountain" do
    it "enters tapped with no Mountain" do
      expect(ResolvePermanent("Arena Of Glory", owner: p1)).to be_tapped
    end

    it "enters untapped with a Mountain" do
      ResolvePermanent("Mountain", owner: p1)

      expect(ResolvePermanent("Arena Of Glory", owner: p1)).not_to be_tapped
    end
  end

  describe "abilities" do
    let!(:mountain) { ResolvePermanent("Mountain", owner: p1) }
    let!(:arena) { ResolvePermanent("Arena Of Glory", owner: p1) }

    it "taps for {R}" do
      p1.activate_ability(ability: arena.activated_abilities.first)

      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "exerts to add {R}{R}" do
      p1.add_mana(red: 1)
      p1.activate_ability(ability: arena.activated_abilities.last) { |a| a.pay_mana(red: 1) }

      expect(p1.restricted_mana.map(&:color)).to eq(%i[red red])
      expect(arena).to be_tapped
    end

    it "does not untap during your next untap step after exerting" do
      p1.add_mana(red: 1)
      p1.activate_ability(ability: arena.activated_abilities.last) { |a| a.pay_mana(red: 1) }
      game.next_turn
      game.next_turn
      go_to_main_phase!

      expect(arena).to be_tapped
    end

    it "gives a creature spell cast with that mana haste" do
      p1.add_mana(red: 1)
      p1.activate_ability(ability: arena.activated_abilities.last) { |a| a.pay_mana(red: 1) }
      p1.add_mana(green: 1)
      bears = Card("Grizzly Bears", owner: p1) # {1}{G}
      p1.hand.add(bears)

      p1.cast(card: bears) { |a| a.pay_mana(generic: { red: 1 }, green: 1) }
      game.stack.resolve!
      game.tick!

      expect(p1.creatures.find { _1.name == "Grizzly Bears" }).not_to be_summoning_sick
    end

    it "gives no haste to a creature spell paid for with other mana" do
      p1.add_mana(red: 1)
      p1.activate_ability(ability: arena.activated_abilities.last) { |a| a.pay_mana(red: 1) }
      p1.add_mana(green: 2)
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)

      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
      game.tick!

      expect(p1.creatures.find { _1.name == "Grizzly Bears" }).to be_summoning_sick
    end

    it "gives no haste without the exerted mana" do
      p1.add_mana(green: 1, red: 1)
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)

      p1.cast(card: bears) { |a| a.pay_mana(generic: { red: 1 }, green: 1) }
      game.stack.resolve!
      game.tick!

      expect(p1.creatures.find { _1.name == "Grizzly Bears" }).to be_summoning_sick
    end
  end
end
