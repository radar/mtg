require 'spec_helper'

RSpec.describe Magic::Game, "replacement effects -- source eligibility" do
  include_context "two player game"

  let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  let(:counter_effect) do
    Magic::Effects::AddCounterToPermanent.new(
      source: wood_elves,
      counter_type: Magic::Counters::Plus1Plus1,
      target: wood_elves,
      amount: 1,
    )
  end

  it "applies replacement from eligible battlefield sources" do
    game.add_effect(counter_effect)

    expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
  end

  it "does not apply replacement from phased-out sources" do
    doubling_season.phase_out!

    game.add_effect(counter_effect)

    expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end
end
