require 'spec_helper'

RSpec.describe Magic::Cards::PrimalMight do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog", owner: p2) }

  let(:primal_might) { Card("Primal Might") }

  it "wood elves get +3/+3, fight alpine watchdog" do
    p1.add_mana(green: 4)
    p1.cast(card: primal_might, value_for_x: 3) do
      _1.targeting(wood_elves, alpine_watchdog)
      _1.pay_mana(green: 1, x: { green: 3 })
    end
    game.tick!

    expect(wood_elves.power).to eq(4)
    expect(alpine_watchdog.damage).to eq(4)
  end
end
