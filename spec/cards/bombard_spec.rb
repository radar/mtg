require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:wood_elves) { Magic::Cards::WoodElves.new(controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(wood_elves)
  end

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    card.cast!
    game.stack.resolve!
    expect(wood_elves.zone).to be_graveyard
  end
end
