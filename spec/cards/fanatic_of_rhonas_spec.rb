# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FanaticOfRhonas do
  include_context "two player game"

  let!(:fanatic) { ResolvePermanent("Fanatic Of Rhonas", owner: p1) }

  it "taps for {G}" do
    p1.activate_ability(ability: fanatic.activated_abilities.first)

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "can't tap for {G}{G}{G}{G} without a creature with power 4 or greater" do
    expect { p1.activate_ability(ability: fanatic.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
  end

  it "taps for {G}{G}{G}{G} with a power-4 creature" do
    ResolvePermanent("Colossal Dreadmaw", owner: p1)
    p1.activate_ability(ability: fanatic.activated_abilities.last)

    expect(p1.mana_pool[:green]).to eq(4)
  end

  context "eternalize" do
    before do
      go_to_main_phase!
      fanatic.destroy!
      game.settle!
      p1.add_mana(green: 4)
    end

    let(:card) { p1.graveyard.cards.find { _1.name == "Fanatic of Rhonas" } }

    def eternalize
      p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 2 }, green: 2) }
      game.stack.resolve!
      game.settle!
    end

    it "makes a 4/4 black Zombie Snake Druid copy" do
      eternalize
      token = p1.creatures.first

      expect(token.name).to eq("Fanatic of Rhonas")
      expect([token.power, token.toughness]).to eq([4, 4])
      expect(token.colors).to eq([:black])
      expect(token.mana_value).to eq(0)
      expect(token.types.map(&:to_s)).to include("Zombie", "Snake", "Druid")
      expect(p1.graveyard.cards).not_to include(card)
    end
  end
end
