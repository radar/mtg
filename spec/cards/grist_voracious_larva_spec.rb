# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GristVoraciousLarva do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:grist) { ResolvePermanent("Grist, Voracious Larva", owner: p1) }

  def reanimate(card)
    Magic::Permanent.put_onto_battlefield(game:, card:, from_zone: card.zone, controller: p1)
    game.settle!
  end

  it "has deathtouch" do
    expect(grist).to be_deathtouch
  end

  context "when a creature enters from your graveyard" do
    let(:bears) do
      card = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(card)
      card
    end

    it "may pay {G} to flip into the planeswalker" do
      p1.add_mana(green: 1)
      reanimate(bears)
      game.resolve_choice!
      game.settle!

      walker = game.battlefield.controlled_by(p1).find { _1.name == "Grist, the Plague Swarm" }
      expect(walker).to be_planeswalker
      expect(walker.loyalty).to eq(3)
      expect(game.battlefield.controlled_by(p1).map(&:name)).not_to include("Grist, Voracious Larva")
    end

    it "does nothing when the player declines" do
      p1.add_mana(green: 1)
      reanimate(bears)
      game.skip_choice!
      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Grist, Voracious Larva")
    end

    it "does nothing without {G} available" do
      reanimate(bears)
      expect(game.choices).to be_empty
    end
  end

  it "does not trigger for a creature that did not enter from the graveyard" do
    p1.add_mana(green: 1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    expect(game.choices).to be_empty
  end

  context "as a planeswalker" do
    let!(:walker) do
      grist.exile_and_return_transformed!
      game.settle!
      game.battlefield.controlled_by(p1).find { _1.name == "Grist, the Plague Swarm" }
    end

    def activate(index, &block)
      p1.activate_loyalty_ability(ability: walker.loyalty_abilities[index], &block)
      game.stack.resolve!
      game.settle!
    end

    def insects = game.battlefield.controlled_by(p1).creatures.select { _1.type?("Insect") && _1.token? }

    it "+1 creates an Insect and mills two" do
      activate(0)
      expect(insects.count).to eq(1)
      expect(p1.graveyard.cards.count).to eq(2)
      expect(walker.loyalty).to eq(4)
    end

    it "-2 destroys target artifact or enchantment" do
      simulacrum = ResolvePermanent("Solemn Simulacrum", owner: p2)
      game.skip_choice! while game.choices.any?
      activate(1) { _1.targeting(simulacrum) }
      expect(p2.graveyard.cards.map(&:name)).to include("Solemn Simulacrum")
      expect(walker.loyalty).to eq(1)
    end

    it "-6 copies each creature card in the graveyard as a 1/1 Insect" do
      walker.change_loyalty!(3)
      p1.graveyard.add(Card("Serra Angel", owner: p1))
      activate(2)
      copy = insects.find { _1.name == "Serra Angel" }
      expect(copy).not_to be_nil
      expect([copy.power, copy.toughness]).to eq([1, 1])
    end
  end
end
