require 'spec_helper'

RSpec.describe Magic::Cards::BojukaBog do
  include_context "two player game"

  it "exiles a target player's graveyard when it enters" do
    victim = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(victim)
    ResolvePermanent("Bojuka Bog", owner: p1)

    game.resolve_choice!(target: p2)

    expect(p2.graveyard.cards).to be_empty
    expect(game.exile.cards).to include(victim)
  end
end
