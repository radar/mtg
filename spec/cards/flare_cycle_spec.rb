# frozen_string_literal: true

require "spec_helper"

RSpec.describe "The Flare cycle" do
  include_context "two player game"

  before { go_to_main_phase! }

  describe Magic::Cards::FlareOfDenial do
    let(:flare) { Card("Flare Of Denial", owner: p1) }
    let(:bolt) { Card("Lightning Bolt", owner: p2) }

    let!(:mage) { ResolvePermanent("Dreamtide Whale", owner: p1) }

    before do
      p1.hand.add(flare)
      p2.add_mana(red: 1)
      p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p1) }
    end

    it "counters target spell for its mana cost" do
      p1.add_mana(blue: 3)
      p1.cast(card: flare) { |a| a.pay_mana(generic: { blue: 1 }, blue: 2).targeting(game.stack.spells.first) }
      game.stack.resolve!

      expect(bolt.zone).to be_graveyard
      expect(p1.life).to eq(20)
    end

    it "can be cast by sacrificing a nontoken blue creature" do
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect(action.can_perform?).to eq(true)
      action.pay_cost(mage)
      action.targeting(game.stack.spells.first)
      action.perform
      game.stack.resolve!

      expect(mage.zone).to be_nil
      expect(bolt.zone).to be_graveyard
    end

    it "cannot sacrifice a nonblue creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect { action.pay_cost(bears) }.to raise_error(RuntimeError, /Invalid creature/)
    end
  end

  describe Magic::Cards::FlareOfCultivation do
    let(:flare) { Card("Flare Of Cultivation", owner: p1) }

    it "puts one basic land onto the battlefield tapped and another into hand" do
      p1.hand.add(flare)
      p1.add_mana(green: 3)
      p1.cast(card: flare) { |a| a.pay_mana(generic: { green: 1 }, green: 2) }
      game.stack.resolve!
      game.settle!
      forests = p1.library.select { _1.name == "Forest" }
      skip "no forests in library" if forests.size < 2
      hand = p1.hand.cards.size

      game.resolve_choice!(targets: [forests[0]])
      game.resolve_choice!(targets: [forests[1]])

      expect(p1.lands.count { _1.name == "Forest" && _1.tapped? }).to eq(1)
      expect(p1.hand.cards.size).to eq(hand + 1)
    end
  end

  describe "Flare of Cultivation's alternative cost" do
    let(:flare) { Card("Flare Of Cultivation", owner: p1) }

    it "can be cast by sacrificing a nontoken green creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect(action.can_perform?).to eq(true)
      action.pay_cost(bears)
      action.perform

      expect(bears.zone).to be_nil
      expect(game.stack.spells.map(&:card)).to include(flare)
    end

    it "cannot sacrifice a nongreen creature" do
      corpse = ResolvePermanent("Walking Corpse", owner: p1)
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect { action.pay_cost(corpse) }.to raise_error(RuntimeError, /Invalid creature/)
    end
  end

  describe "Flare of Malice's alternative cost" do
    let(:flare) { Card("Flare Of Malice", owner: p1) }

    it "can be cast by sacrificing a nontoken black creature" do
      corpse = ResolvePermanent("Walking Corpse", owner: p1)
      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect(action.can_perform?).to eq(true)
      action.pay_cost(corpse)
      action.perform
      game.stack.resolve!
      game.settle!

      expect(corpse.zone).to be_nil
      expect(victim.zone).to be_nil
    end

    it "cannot sacrifice a nonblack creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      action = cast_action_as(:alternative, card: flare, player: p1)
      expect { action.pay_cost(bears) }.to raise_error(RuntimeError, /Invalid creature/)
    end
  end

  describe Magic::Cards::FlareOfMalice do
    let(:flare) { Card("Flare Of Malice", owner: p1) }

    before do
      p1.hand.add(flare)
      p1.add_mana(black: 4)
    end

    def cast_flare = p1.cast(card: flare) { |a| a.pay_mana(generic: { black: 2 }, black: 2) }

    it "makes the opponent sacrifice their only highest-value creature" do
      small = ResolvePermanent("Grizzly Bears", owner: p2)
      big = ResolvePermanent("Dreamtide Whale", owner: p2)
      cast_flare
      game.stack.resolve!
      game.settle!

      expect(big.zone).to be_nil
      expect(small.zone).to be_battlefield
    end

    it "lets the opponent choose among ties" do
      a = ResolvePermanent("Grizzly Bears", owner: p2)
      b = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_flare
      game.stack.resolve!
      game.settle!

      expect(game.choices.last.choices).to contain_exactly(a, b)
      game.resolve_choice!(sacrifice: b)
      expect(b.zone).to be_nil
      expect(a.zone).to be_battlefield
    end
  end
end
