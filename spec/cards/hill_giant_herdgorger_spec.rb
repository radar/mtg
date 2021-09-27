require 'spec_helper'

RSpec.describe Magic::Cards::HillGiantHerdgorger do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:card) { described_class.new(controller: p1) }

  it "adds 3 life to player's life total" do
    starting_life = p1.life
    card.draw!
    card.cast!
    expect(p1.life).to eq(starting_life + 3)
  end
end
