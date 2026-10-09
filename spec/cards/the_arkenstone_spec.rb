# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheArkenstone do
  include_context "two player game"

  let(:card) { Card("The Arkenstone", owner: p1) }

  it "gives creatures you control +1/+1, but not the opponent's" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("The Arkenstone", owner: p1)
    game.tick!

    expect([mine.power, mine.toughness]).to eq([3, 3])
    expect([theirs.power, theirs.toughness]).to eq([2, 2])
  end

  it "draws a card at the beginning of your end step" do
    go_to_main_phase!
    ResolvePermanent("The Arkenstone", owner: p1)
    library_before = p1.library.count
    current_turn.end!
    game.settle!

    expect(p1.library.count).to eq(library_before - 1)
  end

  context "Seek the Heart" do
    before do
      go_to_main_phase!
      p1.hand.add(card)
    end

    it "searches for a legendary creature card and exiles the card on an adventure" do
      legend = Card("Radha, Heart Of Keld", owner: p1)
      p1.library.add(legend)
      p1.add_mana(white: 3)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 2 }, white: 1) }
      game.stack.resolve!

      choice = game.choices.last
      expect(choice.choices).to include(legend)
      expect(choice.choices.all?(&:legendary?)).to eq(true)
      game.resolve_choice!(targets: [legend])

      expect(p1.hand.cards).to include(legend)
      expect(card.zone).to be_exile
    end

    it "can then be cast as the artifact from exile" do
      p1.add_mana(white: 3)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 2 }, white: 1) }
      game.stack.resolve!
      game.skip_choice!
      p1.add_mana(colorless: 5)
      p1.cast(card:) { _1.pay_mana(generic: { colorless: 5 }) }
      game.stack.resolve!

      expect(p1.permanents.map(&:name)).to include("The Arkenstone")
    end
  end
end
