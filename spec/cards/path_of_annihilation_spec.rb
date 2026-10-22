# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PathOfAnnihilation do
  include_context "two player game"

  before { go_to_main_phase! }

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  context "when it enters" do
    let!(:path) { ResolvePermanent("Path Of Annihilation", owner: p1) }

    it "is a colorless enchantment" do
      expect(path.colors).to be_empty
      expect(path.enchantment?).to be(true)
    end

    it "creates two 0/1 Eldrazi Spawn tokens" do
      expect(spawns.count).to eq(2)
      expect(spawns.map { [_1.power, _1.toughness] }.uniq).to eq([[0, 1]])
    end

    it "lets Eldrazi you control tap for one mana of any color" do
      thief = ResolvePermanent("Thief Of Existence", owner: p1)
      game.tick!

      p1.activate_ability(ability: thief.activated_abilities.first) { |a| a.choose(:red) }

      expect(p1.mana_pool[:red]).to eq(1)
      expect(thief).to be_tapped
    end

    it "also grants the ability to the Eldrazi Spawn tokens" do
      game.tick!

      expect(spawns.first.activated_abilities.count).to eq(2)
    end

    it "does not grant the ability to non-Eldrazi creatures" do
      bear = ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!

      expect(bear.activated_abilities).to be_empty
    end

    it "does not grant the ability to an opponent's Eldrazi" do
      thief = ResolvePermanent("Thief Of Existence", owner: p2)
      game.tick!

      expect(thief.activated_abilities).to be_empty
    end

    it "gains 4 life when you cast a creature spell with mana value 7 or greater" do
      card = Card("Sire Of Seven Deaths", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 7)

      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 7 }) }
      game.settle!

      expect(p1.life).to eq(24)
    end

    it "does not gain life for a creature spell with mana value 6" do
      card = Card("Archway Angel", owner: p1)
      p1.hand.add(card)
      p1.add_mana(white: 1, green: 5)

      p1.cast(card: card) { |a| a.pay_mana(generic: { green: 5 }, white: 1) }
      game.settle!

      expect(p1.life).to eq(20)
    end

    it "does not gain life when an opponent casts a big creature spell" do
      go_to_main_phase_for!(p2)
      card = Card("Sire Of Seven Deaths", owner: p2)
      p2.hand.add(card)
      p2.add_mana(green: 7)

      p2.cast(card: card) { |a| a.pay_mana(generic: { green: 7 }) }
      game.settle!

      expect(p1.life).to eq(20)
    end
  end
end
