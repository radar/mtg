require 'spec_helper'

RSpec.describe Magic::Cards::UginTheSpiritDragon do
  include_context "two player game"

  subject(:ugin) { ResolvePermanent("Ugin, The Spirit Dragon", controller: p1) }

  context "+2 triggered ability" do
    let(:ability) { subject.loyalty_abilities.first }
    let(:wood_elves) { ResolvePermanent("Wood Elves", controller: p2) }

    it "targets the wood elves" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: ugin, ability: ability)
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      expect(subject.loyalty).to eq(9)
      expect(wood_elves.damage).to eq(3)
    end

    it "targets the other player" do
      p2_starting_life = p2.life
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: ugin, ability: ability)
        .targeting(p2)
      game.take_action(action)
      game.stack.resolve!
      expect(p2.life).to eq(p2_starting_life - 3)
    end
  end

  context "-X triggered ability" do
    let(:ability) { subject.loyalty_abilities[1] }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p2) }
    let!(:sol_ring) { ResolvePermanent("Sol Ring", controller: p2) }

    it "exiles wood elves, leaves the sol ring" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: ugin, ability: ability)
        .value_for_x(3)
      game.take_action(action)
      game.stack.resolve!
      expect(subject.loyalty).to eq(4)
      # Wood elves has a color, so it goes
      expect(wood_elves.zone).to be_exile
      # Meanwhile, Sol Ring is colorless, so it stays
      expect(sol_ring.zone).to be_battlefield
    end
  end

  context "-10 ultimate ability" do
    let(:ability) { subject.loyalty_abilities[2] }
    let(:forest) { Card("Forest") }
    let(:glorious_anthem) { Card("Glorious Anthem") }
    let(:acidic_slime) { Card("Acidic Slime") }
    let(:fencing_ace) { Card("Fencing Ace") }
    let(:great_furnace) { Card("Great Furnace") }
    let(:island) { Card("Island") }
    let(:mountain) { Card("Mountain") }


    before do
      p1.library.add(glorious_anthem)
      p1.library.add(acidic_slime)
      p1.library.add(fencing_ace)
      p1.library.add(great_furnace)
      p1.library.add(island)
      p1.library.add(mountain)
      p1.library.add(forest)
    end

    it "controller gains 7 life, draws 7 cards and moves 7 permanents to the battlefield" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: ugin, ability: ability)
      game.take_action(action)
      game.stack.resolve!
      expect(subject.loyalty).to eq(0)
      expect(subject.zone).to be_nil
      expect(p1.life).to eq(27)

      move_to_battlefield = game.next_effect
      expect(move_to_battlefield).to be_a(Magic::Effects::MoveToBattlefield)
      permanents = p1.hand.cards.permanents.last(7)
      expect(permanents.count).to eq(7)
      game.resolve_pending_effect(permanents)

      permanents.each do |permanent|
        expect(game.battlefield.cards.by_name(permanent.name).controlled_by(p1).count).to eq(1)
      end
    end
  end
end
