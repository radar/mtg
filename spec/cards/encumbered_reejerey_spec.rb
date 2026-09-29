# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EncumberedReejerey do
  include_context "two player game"

  let!(:reejerey) { ResolvePermanent("Encumbered Reejerey", owner: p1) }

  def counters = reejerey.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "enters with three -1/-1 counters, so it is a 2/1" do
    game.tick!

    expect(counters).to eq(3)
    expect([reejerey.power, reejerey.toughness]).to eq([2, 1])
  end

  it "loses a -1/-1 counter whenever it becomes tapped" do
    reejerey.tap!
    game.settle!

    expect(counters).to eq(2)
  end

  it "does not lose one when another creature becomes tapped" do
    ResolvePermanent("Grizzly Bears", owner: p1).tap!
    game.settle!

    expect(counters).to eq(3)
  end

  it "stops when it has no -1/-1 counters" do
    3.times do
      reejerey.untap!
      reejerey.tap!
      game.settle!
    end
    reejerey.untap!
    reejerey.tap!
    game.settle!

    expect(counters).to eq(0)
  end
end
