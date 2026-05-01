# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SabertoothMauler do
  include_context "two player game"

  let!(:mauler) { ResolvePermanent("Sabertooth Mauler") }

  context "when no creature has died" do
    it "does not add a counter or untap" do
      mauler.tap!
      game.current_turn.end!
      expect(mauler.counters).to be_empty
      expect(mauler).to be_tapped
    end
  end

  context "when a creature has died on controller's end step" do
    before do
      wood_elves = ResolvePermanent("Wood Elves", owner: p2)
      wood_elves.destroy!
    end

    it "puts a +1/+1 counter on Sabertooth Mauler and untaps it" do
      mauler.tap!
      game.current_turn.end!
      expect(mauler.counters.count).to eq(1)
      expect(mauler.counters.first).to be_a(Magic::Counters::Plus1Plus1)
      expect(mauler).to be_untapped
    end
  end

  context "when a creature has died on opponent's end step" do
    before do
      game.next_turn
      wood_elves = ResolvePermanent("Wood Elves", owner: p2)
      wood_elves.destroy!
    end

    it "does not trigger" do
      mauler.tap!
      game.current_turn.end!
      expect(mauler.counters).to be_empty
      expect(mauler).to be_tapped
    end
  end
end
