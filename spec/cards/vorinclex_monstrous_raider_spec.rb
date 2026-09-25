# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VorinclexMonstrousRaider do
  include_context "two player game"

  let!(:vorinclex) { ResolvePermanent("Vorinclex, Monstrous Raider", owner: p1) }
  let!(:my_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:their_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  def plus_counters(permanent) = permanent.counters.count { _1.is_a?(Magic::Counters::Plus1Plus1) }

  it "is a 6/6 legendary Phyrexian Praetor with trample and haste" do
    expect(vorinclex.power).to eq(6)
    expect(vorinclex.toughness).to eq(6)
    expect(vorinclex.type?("Praetor")).to be true
    expect(vorinclex).to be_trample
    expect(vorinclex).to be_haste
  end

  it "doubles counters you put on a permanent" do
    my_elves.add_counter("+1/+1")
    expect(plus_counters(my_elves)).to eq(2)
  end

  it "doubles counters you put on an opponent's permanent" do
    my_elves.trigger_effect(:add_counter, target: their_elves, counter_type: "+1/+1", amount: 3)
    expect(plus_counters(their_elves)).to eq(6)
  end

  it "doubles counters you put on a player" do
    my_elves.trigger_effect(:add_counter, target: p2, counter_type: "poison", amount: 2)
    expect(p2.counters.count).to eq(4)
  end

  it "halves counters an opponent puts, rounded down" do
    their_elves.trigger_effect(:add_counter, target: my_elves, counter_type: "+1/+1", amount: 3)
    expect(plus_counters(my_elves)).to eq(1)
  end

  it "puts no counters when an opponent would put just one" do
    their_elves.add_counter("+1/+1")
    expect(plus_counters(their_elves)).to eq(0)
  end

  it "halves counters an opponent puts on a player" do
    their_elves.trigger_effect(:add_counter, target: p1, counter_type: "poison", amount: 5)
    expect(p1.counters.count).to eq(2)
  end

  it "leaves counters alone once Vorinclex is gone" do
    vorinclex.destroy!
    my_elves.add_counter("+1/+1")
    expect(plus_counters(my_elves)).to eq(1)
  end
end
