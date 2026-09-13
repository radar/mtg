require "spec_helper"

RSpec.describe Magic::Game, "Aron, Benalia's Ruin + Doubling Season" do
  include_context "two player game"

  let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
  let!(:aron) { ResolvePermanent("Aron, Benalia's Ruin", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "puts two +1/+1 counters on each creature you control instead of one" do
    p1.add_mana(white: 1, black: 1)

    p1.activate_ability(ability: aron.activated_abilities.first) do
      _1.pay_mana(white: 1, black: 1)
      _1.pay_sacrifice(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(aron.power).to eq(5)
    expect(aron.toughness).to eq(5)
  end
end
