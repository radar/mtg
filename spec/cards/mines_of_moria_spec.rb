# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MinesOfMoria do
  include_context "two player game"

  let!(:mines) { ResolvePermanent("Mines Of Moria", owner: p1) }
  let(:graveyard_cards) { 3.times.map { Card("Island", owner: p1).tap { p1.graveyard.add(_1) } } }

  def ability(name) = mines.activated_abilities.find { _1.is_a?(described_class.const_get(name)) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def activate
    mines.untap!
    p1.add_mana(red: 4)
    p1.activate_ability(ability: ability(:TreasureAbility)) do |a|
      a.pay_mana(generic: { red: 3 }, red: 1).pay_exile_from_graveyard(graveyard_cards)
    end
    game.stack.resolve!
    game.settle!
  end

  describe "enters tapped unless you control a legendary creature" do
    it "enters tapped with no legendary creature" do
      expect(mines).to be_tapped
    end

    it "enters tapped with only a nonlegendary creature" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(ResolvePermanent("Mines Of Moria", owner: p1)).to be_tapped
    end

    it "enters tapped when only an opponent controls a legendary creature" do
      ResolvePermanent("Lotho Corrupt Shirriff", owner: p2)

      expect(ResolvePermanent("Mines Of Moria", owner: p1)).to be_tapped
    end

    it "enters untapped with a legendary creature" do
      ResolvePermanent("Lotho Corrupt Shirriff", owner: p1)

      expect(ResolvePermanent("Mines Of Moria", owner: p1)).not_to be_tapped
    end
  end

  it "taps for {R}" do
    mines.untap!
    p1.activate_ability(ability: mines.activated_abilities.find { _1.is_a?(Magic::ManaAbility) })

    expect(p1.mana_pool[:red]).to eq(1)
  end

  describe "treasure ability" do
    it "creates two Treasures, tapping the land and exiling three graveyard cards" do
      cards = graveyard_cards
      activate

      expect(treasures.count).to eq(2)
      expect(mines).to be_tapped
      expect(p1.graveyard.cards).to be_empty
      expect(cards.map(&:zone)).to all(be_exile)
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "can't be activated with fewer than three cards in the graveyard" do
      mines.untap!
      2.times { p1.graveyard.add(Card("Island", owner: p1)) }
      p1.add_mana(red: 4)

      expect do
        p1.activate_ability(ability: ability(:TreasureAbility)) do |a|
          a.pay_mana(generic: { red: 3 }, red: 1).pay_exile_from_graveyard(p1.graveyard.cards.first(2))
        end
      end.to raise_error(StandardError)
      expect(treasures).to be_empty
    end
  end
end
