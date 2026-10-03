# frozen_string_literal: true

require "spec_helper"

# A card in the graveyard keeps listening to game events only for handlers that opt in with
# `works_from_graveyard?` (Bloodghast, Repeated Reverberation; see their specs). A destroyed
# permanent's ordinary triggers must stop.
RSpec.describe "event handlers of a card in the graveyard" do
  include_context "two player game"

  it "stop firing once the permanent has died" do
    ResolvePermanent("Good-Fortune Unicorn", owner: p1).destroy!
    game.settle!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(bears.counters.count).to eq(0)
  end
end
