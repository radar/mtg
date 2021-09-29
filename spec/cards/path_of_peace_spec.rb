require 'spec_helper'

RSpec.describe Magic::Cards::PathOfPeace do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new(controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(loxodon_wayfarer)
  end

  it "destroys the great furnace" do
    p2_starting_life = p2.life
    card.cast!
    game.stack.resolve!
    expect(loxodon_wayfarer.zone).to be_graveyard
    expect(p2.life).to eq(p2_starting_life + 4)
  end
end
