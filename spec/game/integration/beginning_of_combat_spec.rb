require 'spec_helper'

RSpec.describe Magic::Game, "beginning of combat on your turn" do
  include_context "two player game"

  before do
    p1.library.add(Card("Forest"))
  end

  context "with basri ket's emblem" do
    before do
      game.emblems << Magic::Cards::BasriKet::Emblem.new(game:, owner: p1)
    end

    it "creates a 1/1 white soldier creature token" do
      skip_to_combat!
      game.tick!

      expect(creatures.count).to eq(1)
      soldier = creatures.first
      expect(soldier.colors).to eq([:white])
      expect(soldier.counters.count).to eq(1)
      counter = soldier.counters.first
      expect(counter.power_modification).to eq(1)
      expect(counter.toughness_modification).to eq(1)
      expect(soldier.power).to eq(2)
      expect(soldier.toughness).to eq(2)
    end
  end
end
