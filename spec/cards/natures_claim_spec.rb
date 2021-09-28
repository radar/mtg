require 'spec_helper'

RSpec.describe Magic::Cards::NaturesClaim do
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:great_furnace) { Magic::Cards::GreatFurnace.new(controller: p2) }

  let(:battlefield) { Magic::Battlefield.new(cards: [great_furnace])}
  let(:game) { Magic::Game.new }

  let(:card) { described_class.new(game: game, controller: p1) }

  it "destroys the great furnace" do
    card.cast!
    game.stack.resolve!
    expect(great_furnace).to receive(:destroy!)
    expect(p2).to receive(:gain_life).with(4)
    game.resolve_effect(Magic::Effects::DestroyControllerGainsLife, target: great_furnace)
  end
end
