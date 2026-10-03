# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrimeSpeakerZegana do
  include_context "two player game"

  it "is a 1/1 Merfolk Wizard before counters" do
    zegana = ResolvePermanent("Prime Speaker Zegana", owner: p1)

    expect([zegana.power, zegana.toughness]).to eq([1, 1])
    expect(zegana.type?("Merfolk")).to be(true)
    expect(zegana.type?("Wizard")).to be(true)
  end

  it "enters with no counters and draws one card when you control no other creatures" do
    hand_size = p1.hand.count
    zegana = ResolvePermanent("Prime Speaker Zegana", owner: p1)

    expect(zegana.counters.count).to eq(0)
    expect(zegana.power).to eq(1)
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "enters with X +1/+1 counters, X the greatest power among your other creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Serra Angel", owner: p1)
    zegana = ResolvePermanent("Prime Speaker Zegana", owner: p1)

    expect(zegana.counters.count).to eq(4)
    expect([zegana.power, zegana.toughness]).to eq([5, 5])
  end

  it "draws cards equal to its power when it enters" do
    ResolvePermanent("Serra Angel", owner: p1)
    hand_size = p1.hand.count
    ResolvePermanent("Prime Speaker Zegana", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 5)
  end

  it "ignores the opponent's creatures" do
    ResolvePermanent("Serra Angel", owner: p2)
    zegana = ResolvePermanent("Prime Speaker Zegana", owner: p1)

    expect(zegana.counters.count).to eq(0)
  end
end
