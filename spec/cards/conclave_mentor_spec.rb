require 'spec_helper'

RSpec.describe Magic::Cards::ConclaveMentor do
  include_context "two player game"
  let!(:permanent) { ResolvePermanent("Conclave Mentor") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  it "if one or more counters would be put on a creature you control" do
    effect = Magic::Effects::AddCounterToPermanent.new(
      source: wood_elves,
      counter_type: Magic::Counters::Plus1Plus1,
      target: wood_elves,
    )

    game.add_effect(effect)

    expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
  end


  it "when this dies, gain life equal to its power" do
    effect = Magic::Effects::Sacrifice.new(
      source: permanent,
      target: permanent,
    )

    game.add_effect(effect)

    expect(p1.life).to eq(22)
  end
end
