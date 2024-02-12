require 'spec_helper'

RSpec.describe Magic::Cards::UginTheSpiritDragon do
  include_context "two player game"

  subject(:ugin) { ResolvePermanent("Ugin, The Spirit Dragon", owner: p1) }

  context "+2 triggered ability" do
    let(:ability) { subject.loyalty_abilities.first }
    let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "targets the wood elves" do
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(wood_elves)
      end
      game.stack.resolve!
      expect(subject.loyalty).to eq(9)
      expect(wood_elves.damage).to eq(3)
    end

    it "targets the other player" do
      p2_starting_life = p2.life
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(p2)
      end
      game.stack.resolve!
      expect(p2.life).to eq(p2_starting_life - 3)
    end
  end

  context "-X triggered ability" do
    let(:ability) { subject.loyalty_abilities[1] }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
    let!(:sol_ring) { ResolvePermanent("Sol Ring", owner: p2) }

    it "exiles wood elves, leaves the sol ring" do
      p1.activate_loyalty_ability(ability: ability) do
        _1.value_for_x(3)
      end
      game.stack.resolve!
      expect(subject.loyalty).to eq(4)
      # Wood elves has a color, so it goes
      expect(wood_elves.card.zone).to be_exile
      # Meanwhile, Sol Ring is colorless, so it stays
      expect(sol_ring.zone).to be_battlefield
    end
  end

  context "-10 ultimate ability" do
    let(:ability) { subject.loyalty_abilities[2] }
    let(:forest) { Card("Forest") }
    let(:glorious_anthem) { Card("Glorious Anthem") }
    let(:wood_elves) { Card("Wood Elves") }
    let(:fencing_ace) { Card("Fencing Ace") }
    let(:great_furnace) { Card("Great Furnace") }
    let(:island) { Card("Island") }
    let(:mountain) { Card("Mountain") }


    before do
      p1.library.add(glorious_anthem)
      p1.library.add(wood_elves)
      p1.library.add(fencing_ace)
      p1.library.add(great_furnace)
      p1.library.add(island)
      p1.library.add(mountain)
      p1.library.add(forest)
    end

    it "controller gains 7 life, draws 7 cards and moves 7 permanents to the battlefield" do
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      expect(subject.loyalty).to eq(0)
      expect(subject.zone).to be_nil
      expect(p1.life).to eq(27)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::UginTheSpiritDragon::Choice)
      permanents = p1.hand.cards.permanents.first(7)
      expect(permanents.count).to eq(7)
      game.resolve_choice!(choices: permanents)

      permanents.each do |permanent|
        expect(game.battlefield.cards.by_name(permanent.name).controlled_by(p1).count).to eq(1)
      end
    end
  end
end
