require 'spec_helper'

RSpec.describe Magic::Cards::Shatter do
  include_context "two player game"

  let(:great_furnace) { Card("Great Furnace", game: game, controller: p1) }
  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(great_furnace)
  end

  it "destroys the great furnace" do
    card.cast!
    game.stack.resolve!
    expect(great_furnace.zone).to be_graveyard
  end
end
