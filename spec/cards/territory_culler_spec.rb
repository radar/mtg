# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TerritoryCuller do
  include_context "two player game"

  let!(:culler) { ResolvePermanent("Territory Culler", owner: p1) }

  def top!(name)
    card = Card(name, owner: p1)
    p1.library.add(card)
    card
  end

  def land_enters!(owner: p1)
    ResolvePermanent("Forest", owner: owner)
    game.settle!
  end

  it "is a colorless 7/5 Eldrazi with reach" do
    expect([culler.power, culler.toughness]).to eq([7, 5])
    expect(culler.type?("Eldrazi")).to be(true)
    expect(culler.card.colors).to be_empty
    expect(culler.keywords).to include(Magic::Cards::Keywords::REACH)
  end

  context "when the top card is a creature" do
    let!(:top) { top!("Grizzly Bears") }

    it "may reveal it and put it into your hand" do
      land_enters!
      hand = p1.hand.count
      game.resolve_choice!

      expect(top.zone).to eq(p1.hand)
      expect(p1.hand.count).to eq(hand + 1)
      expect(game.choices).to be_empty
    end

    it "then, if you decline, may put it into your graveyard" do
      land_enters!
      game.skip_choice!
      expect(top.zone).to eq(p1.library)
      game.resolve_choice!

      expect(top.zone).to eq(p1.graveyard)
    end

    it "leaves it on top if you decline both" do
      land_enters!
      game.skip_choice!
      game.skip_choice!

      expect(top.zone).to eq(p1.library)
      expect(p1.library.cards.first).to eq(top)
    end

    it "does not offer the graveyard once you took it into hand" do
      land_enters!
      game.resolve_choice!

      expect(game.choices).to be_empty
    end

    it "does not trigger for an opponent's land" do
      land_enters!(owner: p2)

      expect(game.choices).to be_empty
      expect(top.zone).to eq(p1.library)
    end
  end

  context "when the top card is not a creature" do
    let!(:top) { top!("Sol Ring") }

    it "offers only the graveyard, not the hand" do
      land_enters!
      choice = game.choices.first

      expect(choice).to be_a(Magic::Cards::TerritoryCuller::GraveyardChoice)
      game.resolve_choice!

      expect(top.zone).to eq(p1.graveyard)
      expect(game.choices).to be_empty
    end

    it "leaves it on top if you decline" do
      land_enters!
      game.skip_choice!

      expect(top.zone).to eq(p1.library)
      expect(p1.hand.cards).not_to include(top)
    end
  end

  it "does nothing with an empty library" do
    p1.library.cards.dup.each { p1.library.remove(_1) }
    land_enters!

    expect(game.choices).to be_empty
  end
end
