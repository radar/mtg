# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LastingTarfire do
  include_context "two player game"

  let!(:tarfire) { ResolvePermanent("Lasting Tarfire", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opponents_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def put_counter(on:, source:)
    Magic::Effects::AddCounterToPermanent.new(source: source, target: on, counter_type: "+1/+1").resolve!
  end

  it "deals 2 damage to each opponent at the end step if you put a counter on a creature this turn" do
    put_counter(on: bears, source: tarfire)
    current_turn.end!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
  end

  it "counts a counter put on an opponent's creature" do
    put_counter(on: opponents_bears, source: tarfire)
    current_turn.end!

    expect(p2.life).to eq(18)
  end

  it "does nothing if no counter was put on a creature this turn" do
    current_turn.end!

    expect(p2.life).to eq(20)
  end

  it "doesn't count a counter put on a creature by an opponent" do
    put_counter(on: bears, source: opponents_bears)
    current_turn.end!

    expect(p2.life).to eq(20)
  end

  it "doesn't count a counter put on something that isn't a creature" do
    put_counter(on: tarfire, source: tarfire)
    current_turn.end!

    expect(p2.life).to eq(20)
  end
end
