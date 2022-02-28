require 'spec_helper'

RSpec.describe Magic::Cards::GolgariGuildgate do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  it "enters the battlefield tapped" do
    card.cast!
    game.stack.resolve!
    expect(card).to be_tapped
  end

  it "taps for either black or green" do
    card.cast!
    card.untap!
    card.tap!
    game.resolve_pending_effect(black: 1)
    expect(game.effects).to be_empty
    expect(p1.mana_pool[:black]).to eq(1)
  end
end
