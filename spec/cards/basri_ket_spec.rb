require 'spec_helper'

RSpec.describe Magic::Cards::BasriKet do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  context "+1 triggered ability" do
    subject { Card("Basri Ket", controller: p1) }
    let(:ability) { subject.loyalty_abilities.first }
    let(:wood_elves) { Card("Wood Elves", controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "targets the wood elves" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(4)
      expect(game.effects.count).to eq(1)
      expect(game.next_effect).to be_a(Magic::Effects::AddCounter)
      game.resolve_effect(game.next_effect, target: wood_elves)
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
      expect(wood_elves.indestructible?).to eq(true)
    end
  end
end
