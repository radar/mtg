require 'spec_helper'

RSpec.describe Magic::Cards::Shatter do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:great_furnace) { Magic::Cards::GreatFurnace.new(controller: p1) }
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
