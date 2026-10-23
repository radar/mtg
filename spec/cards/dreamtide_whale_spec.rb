# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreamtideWhale do
  include_context "two player game"

  before { go_to_main_phase! }

  def time_counters(permanent) = permanent.counters.of_type(Magic::Counters::Time).count

  def upkeep!(player)
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: player))
    game.settle!
  end

  context "when cast" do
    it "is a 7/5 that enters with two time counters" do
      p1.add_mana(blue: 1, green: 2)
      p1.cast(card: Card("Dreamtide Whale", owner: p1)) { |a| a.pay_mana(blue: 1, generic: { green: 2 }) }
      game.stack.resolve!
      whale = p1.creatures.find { _1.name == "Dreamtide Whale" }

      expect([whale.power, whale.toughness]).to eq([7, 5])
      expect(time_counters(whale)).to eq(2)
    end
  end

  context "with vanishing" do
    let!(:whale) { ResolvePermanent("Dreamtide Whale", owner: p1) }

    it "removes a time counter at the beginning of your upkeep" do
      upkeep!(p1)

      expect(time_counters(whale)).to eq(1)
      expect(whale.zone).not_to be_nil
    end

    it "sacrifices itself when the last counter is removed" do
      2.times { upkeep!(p1) }

      expect(time_counters(whale)).to eq(0)
      expect(p1.graveyard.cards.map(&:name)).to include("Dreamtide Whale")
    end

    it "ignores an opponent's upkeep" do
      upkeep!(p2)

      expect(time_counters(whale)).to eq(2)
    end
  end

  context "when a player casts their second spell each turn" do
    let!(:whale) { ResolvePermanent("Dreamtide Whale", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { bears.add_counter("+1/+1") }

    def cast_bolt
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }) do |a|
        a.pay_mana(red: 1)
        a.targeting(p2)
      end
      game.settle!
    end

    it "proliferates on the second spell only" do
      cast_bolt
      expect(game.choices).to be_empty

      cast_bolt
      game.resolve_choice!(chosen: [bears])

      expect(bears.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end
  end
end
