require 'spec_helper'

RSpec.describe Magic::Game, "replacement effects -- chooser controls application order" do
  include_context "two player game"

  let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
  let!(:conclave_mentor) { ResolvePermanent("Conclave Mentor", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  def counter_effect
    Magic::Effects::AddCounterToPermanent.new(
      source: wood_elves,
      counter_type: "+1/+1",
      target: wood_elves,
      amount: 1,
    )
  end

  context "when chooser applies doubling season first" do
    before do
      allow(p1).to receive(:choose_replacement_effect) do |replacement_effects:, **_args|
        replacement_effects.find { |effect| effect.is_a?(Magic::Cards::DoublingSeason::CounterDoubler) } || replacement_effects.first
      end
    end

    it "adds 3 counters" do
      game.add_effect(counter_effect)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(3)
    end
  end

  context "when chooser applies conclave mentor first" do
    before do
      allow(p1).to receive(:choose_replacement_effect) do |replacement_effects:, **_args|
        replacement_effects.find { |effect| effect.is_a?(Magic::Cards::ConclaveMentor::AddMoreCounters) } || replacement_effects.first
      end
    end

    it "adds 4 counters" do
      game.add_effect(counter_effect)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(4)
    end
  end
end
