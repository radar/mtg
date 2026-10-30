# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Permanent, "#remove_from_exile" do
  include_context "two player game"

  it "keeps exiled_cards a CardList" do
    permanent = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Forest", owner: p1)
    permanent.exiled_cards << card
    game.exile.add(card)

    permanent.remove_from_exile(card)

    expect(permanent.exiled_cards).to be_a(Magic::CardList)
    expect(permanent.exiled_cards).to be_empty
    expect(game.exile.cards).not_to include(card)
  end
end
