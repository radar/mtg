# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DawnBlessedPennant do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:pennant) { ResolvePermanent("Dawn Blessed Pennant", owner: p1) }

  it "only offers its listed creature types" do
    expect(game.choices.last.choices).to eq(%w[Elemental Elf Faerie Giant Goblin Kithkin Merfolk Treefolk])
    expect { game.resolve_choice!(creature_type: "Human") }.to raise_error(ArgumentError)
  end

  context "with Elf chosen" do
    before { game.resolve_choice!(creature_type: "Elf") }

    it "gains 1 life whenever a permanent of the chosen type enters under your control" do
      ResolvePermanent("Llanowar Elves", owner: p1)

      expect(p1.life).to eq(21)
    end

    it "does not gain life for another type or for an opponent's permanent" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Llanowar Elves", owner: p2)

      expect(p1.life).to eq(20)
    end

    it "returns a card of the chosen type from your graveyard to your hand" do
      elf = Card("Llanowar Elves", owner: p1)
      bears = Card("Grizzly Bears", owner: p1)
      [elf, bears].each { |card| p1.graveyard.add(card) }
      p1.add_mana(green: 2)

      ability = pennant.activated_abilities.find { |a| a.is_a?(described_class::ReturnCard) }
      expect(ability.target_choices).to eq([elf])

      p1.activate_ability(ability: ability) do |a|
        a.targeting(elf)
        a.pay_mana(generic: { green: 2 })
      end
      game.settle!

      expect(elf.zone).to eq(p1.hand)
      expect(bears.zone).to eq(p1.graveyard)
      expect(pennant.zone).not_to be_a(Magic::Zones::Battlefield)
    end
  end
end
