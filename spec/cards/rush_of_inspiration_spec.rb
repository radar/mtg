# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RushOfInspiration do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:rush) { Card("Rush of Inspiration", owner: p1) }

  before do
    p1.hand.items.clear
    p1.hand.add(rush)
  end

  def cast!
    p1.add_mana(blue: 1, red: 2)
    p1.cast(card: rush) { |a| a.pay_mana(generic: { blue: 1 }, red: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "has a hybrid cost of {1}{U/R}{U/R} and a land back face" do
    expect(rush.mana_value).to eq(3)
    expect(rush).to be_instant
    expect(rush.back_face.name).to eq("Crackling Falls")
    expect(rush.back_face).to be_land
  end

  context "with no energy" do
    it "draws two cards, then discards one at random" do
      cast!

      expect(game.choices).to be_empty
      expect(p1.hand.count).to eq(1)
      expect(p1.graveyard.cards.count).to eq(2)
    end
  end

  context "with two energy" do
    before { p1.add_counter("energy", amount: 2) }

    it "keeps both cards and loses the energy when you pay" do
      cast!
      expect(game.choices.first).to be_a(described_class::PayChoice)
      game.resolve_choice!

      expect(p1.energy).to eq(0)
      expect(p1.hand.count).to eq(2)
    end

    it "discards a card at random and keeps the energy when you decline" do
      cast!
      game.skip_choice!

      expect(p1.energy).to eq(2)
      expect(p1.hand.count).to eq(1)
      expect(p1.graveyard.cards.count).to eq(2)
    end
  end

  context "with one energy" do
    it "can't pay, so it discards" do
      p1.add_counter("energy", amount: 1)
      cast!

      expect(game.choices).to be_empty
      expect(p1.energy).to eq(1)
      expect(p1.hand.count).to eq(1)
    end
  end

  context "played as Crackling Falls" do
    before { p1.play_land(land: rush, face: :back) }

    let(:falls) { p1.permanents.by_name("Crackling Falls").first }

    it "enters tapped as a land" do
      expect(falls).to be_land
      expect(falls).to be_tapped
    end

    it "taps for {U} or {R}" do
      falls.untap!
      p1.activate_ability(ability: falls.activated_abilities.first) { _1.choose(:red) }
      expect(p1.mana_pool[:red]).to eq(1)
      falls.untap!
      p1.activate_ability(ability: falls.activated_abilities.first) { _1.choose(:blue) }
      expect(p1.mana_pool[:blue]).to eq(1)
    end
  end
end
