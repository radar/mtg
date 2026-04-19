require 'spec_helper'

RSpec.describe Magic::Game, "replacement effects -- semantic applicability" do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  context "with a subclassed add-counter effect" do
    let(:subclassed_counter_effect) do
      Class.new(Magic::Effects::AddCounterToPermanent)
    end

    it "matches doubling season replacement by base class semantics" do
      ResolvePermanent("Doubling Season", owner: p1)

      effect = subclassed_counter_effect.new(
        source: wood_elves,
        counter_type: Magic::Counters::Plus1Plus1,
        target: wood_elves,
        amount: 1,
      )

      game.add_effect(effect)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "matches conclave mentor replacement by base class semantics" do
      ResolvePermanent("Conclave Mentor", owner: p1)

      effect = subclassed_counter_effect.new(
        source: wood_elves,
        counter_type: Magic::Counters::Plus1Plus1,
        target: wood_elves,
        amount: 1,
      )

      game.add_effect(effect)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end
  end
end
