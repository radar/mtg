# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AuroralProcession do
  include_context "two player game"

  let(:procession) { Card("Auroral Procession", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(procession)
    p1.graveyard.add(bears)
    p1.add_mana(green: 1, blue: 1)
  end

  it "returns a card from your graveyard to your hand" do
    p1.cast(card: procession) { |a| a.pay_mana(green: 1, blue: 1).targeting(bears) }
    game.stack.resolve!

    expect(p1.hand.cards).to include(bears)
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "only targets cards in your own graveyard" do
    theirs = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(theirs)
    expect(procession.target_choices).to include(bears)
    expect(procession.target_choices).not_to include(theirs)
  end
end
