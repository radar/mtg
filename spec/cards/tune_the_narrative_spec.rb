# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TuneTheNarrative do
  include_context "two player game"

  let(:spell) { Card("Tune The Narrative") }

  before do
    p1.hand.add(spell)
    p1.add_mana(blue: 1)
    p1.cast(card: spell) { |a| a.pay_mana(blue: 1) }
  end

  it "draws a card" do
    top = p1.library.first
    library_count = p1.library.count
    game.stack.resolve!
    game.settle!
    expect(p1.library.count).to eq(library_count - 1)
    expect(p1.hand.cards).to include(top)
  end

  it "gives you two energy" do
    game.stack.resolve!
    game.settle!

    expect(p1.energy).to eq(2)
    expect(p2.energy).to eq(0)
    expect(p1.graveyard.cards).to include(spell)
  end
end
