require 'spec_helper'

RSpec.describe Magic::Cards::NaturesClaim do
  include_context "two player game"

  let(:great_furnace) { Card("Great Furnace", game: game, controller: p2) }
  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(great_furnace)
  end

  it "destroys the great furnace" do
    p2_starting_life = p2.life
    card.cast!
    game.stack.resolve!
    expect(great_furnace.zone).to be_graveyard
    expect(p2.life).to eq(p2_starting_life + 4)
  end
end
