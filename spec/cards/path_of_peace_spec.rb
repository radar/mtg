require 'spec_helper'

RSpec.describe Magic::Cards::PathOfPeace do
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new(controller: p2) }

  let(:battlefield) { Magic::Battlefield.new(cards: [loxodon_wayfarer])}
  let(:game) { Magic::Game.new }

  let(:card) { described_class.new(game: game, controller: p1) }

  it "destroys the great furnace" do
    card.cast!
    game.stack.resolve!
    expect(loxodon_wayfarer).to receive(:destroy!)
    expect(p2).to receive(:gain_life).with(4)
    game.resolve_effect(Magic::Effects::DestroyControllerGainsLife, target: loxodon_wayfarer)
  end
end
