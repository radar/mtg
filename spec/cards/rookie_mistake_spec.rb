require 'spec_helper'

RSpec.describe Magic::Cards::RookieMistake do
  include_context "two player game"
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:pack_leader) { ResolvePermanent("Pack Leader", owner: p2) }
  subject(:rookie_mistake) { Card("Rookie Mistake") }

  it "wood elves gets +0/+2, llanowar elves gets -2/+0" do
    p1.add_mana(blue: 1)
    p1.cast(card: rookie_mistake) do
      _1.targeting(wood_elves, pack_leader)
      _1.pay_mana(blue: 1)
    end
    game.stack.resolve!

    expect(wood_elves.toughness).to eq(3)
    expect(pack_leader.power).to eq(0)
  end
end
