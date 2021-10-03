require 'spec_helper'

RSpec.describe Magic::Cards::UginTheSpiritDragon do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  context "+2 triggered ability" do
    subject { Card("Ugin, The Spirit Dragon", controller: p1) }
    let(:ability) { subject.loyalty_abilities.first }
    let(:wood_elves) { Card("Wood Elves", controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "targets the wood elves" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(9)
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

  context "-X triggered ability" do
    subject { Card("Ugin, The Spirit Dragon", controller: p1) }
    let(:ability) { subject.loyalty_abilities[1] }
    let(:wood_elves) { Card("Wood Elves", controller: p2) }
    let(:sol_ring) { Card("Sol Ring", controller: p2) }

    before do
      game.battlefield.add(wood_elves)
      game.battlefield.add(sol_ring)
    end

    it "exiles wood elves, leaves the sol ring" do
      subject.activate_loyalty_ability!(ability, value_for_x: 3)
      expect(subject.loyalty).to eq(4)
      # Wood elves has a color, so it goes
      expect(wood_elves.zone).to be_exile
      # Meanwhile, Sol Ring is colorless, so it stays
      expect(sol_ring.zone).to be_battlefield
    end
  end

  context "-10 ultimate ability" do
    subject { Card("Ugin, The Spirit Dragon", controller: p1, loyalty: 10) }
    let(:ability) { subject.loyalty_abilities[2] }

    before do
      p1.library.add(Card("Forest"))
      p1.library.add(Card("Glorious Anthem"))
      p1.library.add(Card("Acidic Slime"))
      p1.library.add(Card("Great Furnace"))
      p1.library.add(Card("Profane Memento"))
      p1.library.add(Card("Island"))
      p1.library.add(Card("Mountain"))
    end

    it "exiles wood elves, leaves the sol ring" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(0)
      expect(subject.zone).to be_graveyard
      expect(p1.life).to eq(27)
    end
  end
end
