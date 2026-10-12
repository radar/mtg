# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExplorationBroodship do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ship) { ResolvePermanent("Exploration Broodship", owner: p1) }
  let(:charge) { Magic::Counters::Charge }

  def charge_ship!(amount)
    ship.add_counter(charge, amount:)
    game.tick!
  end

  def station(creature)
    p1.activate_ability(ability: ship.activated_abilities.first) { |a| a.pay_multi_tap([creature]) }
    game.stack.resolve!
  end

  it "is a Spacecraft artifact, not a creature" do
    expect(ship).to be_artifact
    expect(ship.types).to include("Spacecraft")
    expect(ship).not_to be_creature
  end

  describe "Station" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "taps another creature and adds charge counters equal to its power" do
      station(bears)

      expect(bears).to be_tapped
      expect(ship.charge_counters).to eq(2)
    end

    it "can tap a summoning-sick creature" do
      sick = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)

      station(sick)

      expect(sick).to be_tapped
      expect(ship.charge_counters).to eq(2)
    end

    it "can't tap an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)

      expect { station(theirs) }.to raise_error(/Tap exactly 1/)
    end

    it "can't be activated at instant speed" do
      p1.library.add(Card("Grizzly Bears", owner: p1))
      current_turn.end!

      expect { station(bears) }.to raise_error(Magic::IllegalAction)
    end
  end

  describe "3+" do
    it "doesn't allow an additional land below 3 charge counters" do
      charge_ship!(2)

      expect(p1.max_lands_per_turn).to eq(1)
    end

    it "allows an additional land each turn at 3 charge counters" do
      charge_ship!(3)

      expect(p1.max_lands_per_turn).to eq(2)
    end
  end

  describe "8+" do
    it "is not a creature or flier at 7 charge counters" do
      charge_ship!(7)

      expect(ship).not_to be_creature
      expect(ship).not_to have_keyword(Magic::Cards::Keywords::FLYING)
    end

    it "is a 4/4 artifact creature with flying at 8 charge counters" do
      charge_ship!(8)

      expect(ship).to be_creature
      expect(ship).to be_artifact
      expect(ship.power).to eq(4)
      expect(ship.toughness).to eq(4)
      expect(ship).to have_keyword(Magic::Cards::Keywords::FLYING)
    end

    context "with eight charge counters" do
      let!(:forest) { ResolvePermanent("Forest", owner: p1) }
      let!(:dead_bears) { Card("Grizzly Bears", owner: p1) }

      before do
        charge_ship!(8)
        p1.graveyard.add(dead_bears)
      end

      it "casts a permanent spell from the graveyard by sacrificing a land" do
        p1.add_mana(green: 2)
        p1.cast(card: dead_bears) do |action|
          action.pay_mana(generic: { green: 1 }, green: 1)
          action.pay_sacrifice(forest)
        end
        game.stack.resolve!

        expect(forest.card.zone).to be_graveyard
        expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      end

      it "can't cast a permanent from the graveyard without sacrificing a land" do
        p1.add_mana(green: 2)

        expect do
          p1.cast(card: dead_bears) { |action| action.pay_mana(generic: { green: 1 }, green: 1) }
        end.to raise_error("Additional costs have not been paid")
      end

      it "works only once each turn" do
        another = Card("Grizzly Bears", owner: p1)
        p1.graveyard.add(another)

        p1.add_mana(green: 4)
        p1.cast(card: dead_bears) do |action|
          action.pay_mana(generic: { green: 1 }, green: 1)
          action.pay_sacrifice(forest)
        end
        game.stack.resolve!

        expect do
          p1.cast(card: another) { |action| action.pay_mana(generic: { green: 1 }, green: 1) }
        end.to raise_error(Magic::IllegalAction, /not in a zone it can be cast from/)
      end
    end
  end
end
