require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(wood_elves)
  end

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    card.cast!
    game.tick!
    expect(wood_elves.zone).to be_graveyard
  end
end
