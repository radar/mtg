# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MithrilCoat do
  include_context "two player game"

  let(:coat_card) { Card("Mithril Coat", owner: p1) }

  def equip(coat, creature)
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: coat.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 3 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a legendary artifact Equipment with flash and indestructible costing {3}" do
    expect(coat_card.legendary?).to be true
    expect(coat_card).to be_a(Magic::Cards::Equipment)
    expect(coat_card.mana_value).to eq(3)
    expect(coat_card.keywords).to include(Magic::Cards::Keywords::FLASH, Magic::Cards::Keywords::INDESTRUCTIBLE)
  end

  it "can be cast at instant speed" do
    p1.hand.add(coat_card)
    p1.add_mana(colorless: 3)
    expect(current_turn.main_phase?).to be false
    expect { p1.cast(card: coat_card) { _1.pay_mana(generic: { colorless: 3 }) } }.not_to raise_error
  end

  it "cannot be destroyed itself" do
    coat = ResolvePermanent("Mithril Coat", owner: p1)

    expect(coat.destroy!).to be false
    expect(game.battlefield.permanents).to include(coat)
  end

  describe "enters trigger" do
    it "attaches to a lone legendary creature you control and grants indestructible" do
      jazal = ResolvePermanent("Jazal Goldmane", owner: p1)
      coat = ResolvePermanent("Mithril Coat", owner: p1)
      game.settle!
      game.tick!

      expect(coat.attached_to).to eq(jazal)
      expect(jazal).to have_keyword(:indestructible)
    end

    it "lets you choose between legendary creatures, never offering nonlegendary or opposing ones" do
      jazal = ResolvePermanent("Jazal Goldmane", owner: p1)
      belladonna = ResolvePermanent("Belladonna Took", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Bard The Bowman", owner: p2)
      coat = ResolvePermanent("Mithril Coat", owner: p1)
      game.settle!

      expect(game.choices.first.choices).to contain_exactly(jazal, belladonna)
      expect(game.choices.first.choices).not_to include(bears, theirs)
      game.resolve_choice!(target: belladonna)
      game.tick!

      expect(coat.attached_to).to eq(belladonna)
    end

    it "does nothing without a legendary creature you control" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Jazal Goldmane", owner: p2)
      coat = ResolvePermanent("Mithril Coat", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
      expect(coat.attached_to).to be_nil
    end

    it "attaches to a legal creature when the choice is skipped, as the target is mandatory" do
      ResolvePermanent("Jazal Goldmane", owner: p1)
      belladonna = ResolvePermanent("Belladonna Took", owner: p1)
      coat = ResolvePermanent("Mithril Coat", owner: p1)
      game.settle!
      legal = game.choices.first.choices.first
      game.skip_choice!

      expect(coat.attached_to).to eq(legal)
      expect([belladonna, game.battlefield.creatures.find { _1.name == "Jazal Goldmane" }]).to include(legal)
    end
  end

  describe "equipped creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:coat) { ResolvePermanent("Mithril Coat", owner: p1) }
    before { go_to_main_phase! }

    it "has equip {3}" do
      ability = coat.activated_abilities.first
      expect(ability.costs.size).to eq(1)
      expect(ability.costs.first.cost[:generic]).to eq(3)
    end

    it "grants indestructible, which stops destruction" do
      expect(bears).not_to have_keyword(:indestructible)
      equip(coat, bears)

      expect(bears).to have_keyword(:indestructible)
      expect(bears.destroy!).to be false
      expect(game.battlefield.permanents).to include(bears)
    end

    it "leaves an unequipped creature destructible" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      equip(coat, bears)

      expect(other).not_to have_keyword(:indestructible)
    end

    it "loses indestructible when the Coat leaves the battlefield" do
      equip(coat, bears)
      expect(bears).to have_keyword(:indestructible)

      coat.sacrifice!
      game.settle!
      game.tick!

      expect(game.battlefield.permanents).not_to include(coat)
      expect(bears).not_to have_keyword(:indestructible)
    end
  end
end
