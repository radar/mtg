require 'spec_helper'

RSpec.describe 'When creatures die, auras attached to them are sent to graveyards' do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  let(:faiths_fetters) { Card("Faith's Fetters", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  before do
    game.battlefield.add(wood_elves)
    faiths_fetters.resolve!
    game.stack.resolve!
  end

  it "wood elves is destroyed" do
    wood_elves.destroy!
    expect(wood_elves.zone).to eq(p2.graveyard)
    expect(faiths_fetters.zone).to eq(p1.graveyard)
  end
end
