# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShadowUrchin do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:urchin) { ResolvePermanent("Shadow Urchin", owner: p1) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 3/4 Ouphe" do
    expect([urchin.power, urchin.toughness]).to eq([3, 4])
  end

  describe "attacking" do
    it "blights 1: puts a -1/-1 counter on a creature you control" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(urchin, target: p2)
      game.notify!(Magic::Events::CreatureAttacked.new(attacker: urchin, target: p2))
      game.settle!
      game.resolve_choice!(target: bears)

      expect(minus_counters(bears)).to eq(1)
    end

    it "can blight itself" do
      skip_to_combat!
      current_turn.declare_attackers!
      game.notify!(Magic::Events::CreatureAttacked.new(attacker: urchin, target: p2))
      game.settle!
      game.resolve_choice!(target: urchin)

      expect(minus_counters(urchin)).to eq(1)
    end

    it "doesn't blight when another creature attacks" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      game.notify!(Magic::Events::CreatureAttacked.new(attacker: bears, target: p2))
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  describe "when a creature you control with counters dies" do
it "exiles that many cards from the top of your library, playable until your next end step" do
  creature = ResolvePermanent("Courser Of Kruphix", owner: p1)
  2.times { creature.add_counter(Magic::Counters::Minus1Minus1) }
  top = p1.library.first(3)
  creature.destroy!
  game.settle!

  expect(top.map { _1.zone.exile? }).to eq([true, true, false])
  expect(top.first(2)).to all(satisfy { |card| game.play_permissions.permits?(card, p1) })
end

    it "exiles exactly one card for a creature with a single counter" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      bears.add_counter(Magic::Counters::Minus1Minus1)
      cards = p1.library.first(2)
      bears.destroy!
      game.settle!

      expect(cards.map { _1.zone.exile? }).to eq([true, false])
    end

    it "ignores a creature without counters" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      top = p1.library.first
      bears.destroy!
      game.settle!

      expect(top.zone).to be_library
    end

    it "ignores the opponent's creatures" do
      theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
      theirs.add_counter(Magic::Counters::Minus1Minus1)
      top = p1.library.first
      theirs.destroy!
      game.settle!

      expect(top.zone).to be_library
    end

    it "lets you play the cards until your next end step (this turn's, when it is your turn)" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      bears.add_counter(Magic::Counters::Minus1Minus1)
      top = p1.library.first
      bears.destroy!
      game.settle!
      expect(game.play_permissions.permits?(top, p1)).to be(true)

      game.next_turn
      go_to_main_phase!
      expect(game.play_permissions.permits?(top, p1)).to be(false)
    end
  end
end
