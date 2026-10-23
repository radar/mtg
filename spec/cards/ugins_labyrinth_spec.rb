# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UginsLabyrinth do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:titan) { Card("Chromatic Orrery", owner: p1) }

  def land = p1.permanents.find { _1.name == "Ugin's Labyrinth" }

  def tap_for_mana(ability_class)
    land.untap!
    ability = land.activated_abilities.find { _1.is_a?(ability_class) }
    p1.activate_ability(ability:)
  end

  context "with no colorless card to imprint" do
    before { ResolvePermanent("Ugin's Labyrinth", owner: p1) }

    it "taps for {C}" do
      p1.mana_pool.clear if p1.mana_pool.respond_to?(:clear)
      tap_for_mana(described_class::ManaAbility)
      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end

  context "with a colorless card with mana value 7 or more in hand" do
    before do
      p1.hand.add(titan)
      ResolvePermanent("Ugin's Labyrinth", owner: p1)
      game.settle!
      game.resolve_choice!(target: titan)
    end

    it "exiles the card" do
      expect(land.exiled_cards).to include(titan)
      expect(p1.hand.cards).not_to include(titan)
    end

    it "taps for {C}{C}" do
      tap_for_mana(described_class::ManaAbility)
      expect(p1.mana_pool[:colorless]).to eq(2)
    end

    it "returns the exiled card to hand" do
      tap_for_mana(described_class::ReturnAbility)
      game.stack.resolve!
      game.settle!
      expect(p1.hand.cards).to include(titan)
    end
  end
end
