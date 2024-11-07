require 'spec_helper'

RSpec.describe Magic::Cards::Eliminate do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  let(:eliminate) { Card("Eliminate") }

  it "destroys the wood elves" do
    p1.add_mana(black: 2)
    action = cast_action(player: p1, card: eliminate)
    action.pay_mana(generic: { black: 1 }, black: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.stack.resolve!
    expect(wood_elves).to be_dead
  end
end
