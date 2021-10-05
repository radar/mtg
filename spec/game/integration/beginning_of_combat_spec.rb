require 'spec_helper'

RSpec.describe Magic::Game, "beginning of combat on your turn" do
  subject(:game) { Magic::Game.new }

  let!(:p1) { game.add_player(library: [Card("Forest")]) }

  context "with basri ket's emblem" do
    before do
      game.emblems << Magic::Cards::BasriKet::Emblem.new(controller: p1)
    end

    it "creates a 1/1 white soldier creature token" do
      until subject.at_step?(:beginning_of_combat)
        subject.next_step
      end

      creatures = game.battlefield.creatures
      expect(creatures.count).to eq(1)
      soldier = creatures.first
      expect(soldier.colors).to eq([:white])
      expect(soldier.counters.count).to eq(1)
      counter = soldier.counters.first
      expect(counter.power).to eq(1)
      expect(counter.toughness).to eq(1)
      expect(soldier.power).to eq(2)
      expect(soldier.toughness).to eq(2)
    end
  end
end
