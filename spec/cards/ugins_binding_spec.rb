# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UginsBinding do
  include_context "two player game"

  let(:binding_card) { Card("Ugins Binding", owner: p1) }

  def cast_binding(target)
    p1.hand.add(binding_card)
    p1.add_mana(blue: 1, colorless: 2)
    p1.cast(card: binding_card) do |a|
      a.pay_mana(generic: { colorless: 2 }, blue: 1)
      a.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a colorless devoid instant" do
    expect(binding_card.colorless?).to eq(true)
    expect(binding_card.cmc).to eq(3)
  end

  describe "bounce" do
    it "returns target nonland permanent you don't control to its owner's hand" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_binding(bears)

      expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
      expect(game.battlefield.permanents).not_to include(bears)
    end

    it "does not offer your own permanents or lands" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      land = ResolvePermanent("Island", owner: p2)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)

      choices = binding_card.target_choices.to_a
      expect(choices).to include(theirs)
      expect(choices).not_to include(mine, land)
    end
  end

  describe "graveyard trigger" do
    let(:big_colorless) { Card("Chromatic Orrery", owner: p1) }

    before do
      go_to_main_phase!
      p1.graveyard.add(binding_card)
    end

    def cast_big(card, who: p1, mana: 7)
      who.hand.add(card)
      who.add_mana(colorless: mana)
      who.cast(card: card) { |a| a.pay_mana(generic: { colorless: mana }) }
      game.settle!
    end

    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:their_land) { ResolvePermanent("Island", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "may exile it and bounce each nonland permanent you don't control on a colorless MV 7+ spell" do
      cast_big(big_colorless)
      game.resolve_choice!

      expect(binding_card.zone).to eq(game.exile)
      expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
      expect(game.battlefield.permanents).to include(their_land, mine)
      expect(game.battlefield.permanents).not_to include(theirs)
    end

    it "does nothing when declined" do
      cast_big(big_colorless)
      game.skip_choice!

      expect(binding_card.zone).to eq(p1.graveyard)
      expect(game.battlefield.permanents).to include(theirs)
    end

    it "does not trigger on a colored spell" do
      sunderflock = Card("Sunderflock", owner: p1)
      p1.hand.add(sunderflock)
      p1.add_mana(colorless: 7, blue: 2)
      p1.cast(card: sunderflock) { |a| a.pay_mana(generic: { colorless: 7 }, blue: 2) }
      game.settle!

      expect(game.choices).to be_empty
    end

    it "does not trigger on a colorless spell with mana value under 7" do
      cast_big(Card("Sol Ring", owner: p1), mana: 1)

      expect(game.choices).to be_empty
    end

    it "does not trigger when an opponent casts" do
      go_to_main_phase_for!(p2)
      cast_big(Card("Chromatic Orrery", owner: p2), who: p2)

      expect(game.choices).to be_empty
    end
  end
end
