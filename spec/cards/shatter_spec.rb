require 'spec_helper'

RSpec.describe Magic::Cards::Shatter do
  let(:p1) { Magic::Player.new(game: game) }
  let(:great_furnace) { double(Magic::Cards::GreatFurnace) }

  let(:battlefield) { Magic::Battlefield.new(cards: [great_furnace])}
  let(:game) { Magic::Game.new }

  let(:card) { described_class.new(game: game, controller: p1) }

  it "destroys the great furnace" do
    card.cast!
    game.stack.resolve!
    expect(great_furnace).to receive(:destroy!)
    game.resolve_effect(Magic::Effects::Destroy, target: great_furnace)
  end
end
