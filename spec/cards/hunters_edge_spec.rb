# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::HuntersEdge do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog", owner: p2) }

  let(:hunters_edge) { Card("Hunter's Edge") }

  it "puts a +1/+1 counter on your creature, then it deals damage equal to its new power to opponent's creature" do
    p1.add_mana(green: 4)
    p1.cast(card: hunters_edge) do
      _1.targeting(wood_elves, alpine_watchdog)
      _1.pay_mana(green: 1, generic: { green: 3 })
    end
    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    expect(alpine_watchdog.damage).to eq(2)
  end

  it "only allows targeting your creature first and an opponent's creature second" do
    p1.hand.add(hunters_edge)
    cast = p1.prepare_cast(card: hunters_edge)
    expect(cast.target_choices[0]).to include(wood_elves)
    expect(cast.target_choices[0]).not_to include(alpine_watchdog)
    expect(cast.target_choices[1]).to include(alpine_watchdog)
    expect(cast.target_choices[1]).not_to include(wood_elves)
  end
end
