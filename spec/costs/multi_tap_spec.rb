# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Costs::MultiTap do
  include_context "two player game"

  let(:source) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:bears) { 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) } }

  it "can be paid only when enough untapped creatures are available" do
    cost = described_class.new(3) { p1.creatures.untapped }
    source
    expect(cost.can_pay?(p1)).to be(false)

    bears
    expect(cost.can_pay?(p1)).to be(true)
  end

  it "taps exactly the named creatures" do
    cost = described_class.new(3) { p1.creatures.untapped }
    cost.pay(player: p1, payment: [source, *bears])

    expect([source, *bears]).to all(be_tapped)
  end

  it "rejects the wrong number, tapped, duplicate or opponent's creatures" do
    cost = described_class.new(3) { p1.creatures.untapped }
    bears.first.tap!

    expect { cost.pay(player: p1, payment: [source, bears.last]) }.to raise_error(/Tap exactly 3/)
    expect { cost.pay(player: p1, payment: [source, *bears]) }.to raise_error(/Tap exactly 3/)
    expect { cost.pay(player: p1, payment: [source, bears.last, ResolvePermanent("Grizzly Bears", owner: p2)]) }.to raise_error(/Tap exactly 3/)
    expect { cost.pay(player: p1, payment: [source, bears.last, bears.last]) }.to raise_error(/Tap exactly 3/)
  end

  it "can be copied with Marshal, as games are, keeping its count but no candidates" do
    cost = described_class.new(3) { p1.creatures.untapped }
    bears

    copy = Marshal.load(Marshal.dump(cost))

    expect(copy.count).to eq(3)
    expect(copy.candidates).to be_empty
  end

  it "only counts creatures of the named type" do
    cost = described_class.new(2) { p1.creatures.by_type("Elf").untapped }
    source
    bears

    expect(cost.can_pay?(p1)).to be(false)
  end
end
