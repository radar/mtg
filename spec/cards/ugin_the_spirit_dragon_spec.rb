require 'spec_helper'

RSpec.describe Magic::Cards::UginTheSpiritDragon do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  subject { Card("Ugin, The Spirit Dragon", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  before do
    game.battlefield.add(wood_elves)
  end

  context "+2 triggered ability" do
    let(:ability) { subject.loyalty_abilities.first }

    it "targets the wood elves" do
      subject.activate_loyalty_ability!(ability)
      expect(game.effects.count).to eq(1)
      expect(game.next_effect).to be_a(Magic::Effects::DealDamage)
      game.resolve_effect(game.next_effect, target: wood_elves)
    end

    it "targets the other player" do
      subject.activate_loyalty_ability!(ability)
      expect(game.effects.count).to eq(1)
      expect(game.next_effect).to be_a(Magic::Effects::DealDamage)
      game.resolve_effect(game.next_effect, target: p2)
    end
  end
end
