require 'spec_helper'

RSpec.describe Magic::Cards::UginTheSpiritDragon do
  include_context "two player game"

  subject { Card("Ugin, The Spirit Dragon", controller: p1) }
  before { game.battlefield.add(subject) }

  context "+2 triggered ability" do
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
    let(:forest) { Card("Forest") }
    let(:glorious_anthem) { Card("Glorious Anthem") }
    let(:acidic_slime) { Card("Acidic Slime") }
    let(:fencing_ace) { Card("Fencing Ace") }
    let(:great_furnace) { Card("Great Furnace") }
    let(:island) { Card("Island") }
    let(:mountain) { Card("Mountain") }


    before do
      p1.library.add(forest)
      p1.library.add(glorious_anthem)
      p1.library.add(acidic_slime)
      p1.library.add(fencing_ace)
      p1.library.add(great_furnace)
      p1.library.add(island)
      p1.library.add(mountain)
      p1.library.add(forest)
    end

    it "controller gains 7 life, draws 7 cards and moves 7 permanents to the battlefield" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(0)
      expect(subject.zone).to be_graveyard
      expect(p1.life).to eq(27)

      move_to_battlefield = game.next_effect
      expect(move_to_battlefield).to be_a(Magic::Effects::MoveToBattlefield)
      permanents = p1.hand.cards.permanents.last(7)
      game.resolve_effect(move_to_battlefield, targets: permanents)

      permanents.each do |permanent|
        expect(permanent.zone).to be_battlefield
      end
    end
  end
end
