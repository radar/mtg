# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Choice::SearchLibrary do
  include_context "two player game"

  let(:card) { Card("Buried Alive", owner: p1) }

  before do
    go_to_main_phase!
    p1.library.add(Card("Grizzly Bears", owner: p1))
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "shuffles the library when the search is skipped" do
    expect(p1).to receive(:shuffle!)
    game.skip_choice!
  end

  it "leaves the library cards in place when skipped" do
    game.skip_choice!
    expect(p1.graveyard.cards.map(&:name)).to eq(["Buried Alive"])
  end
end
