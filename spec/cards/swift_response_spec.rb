require 'spec_helper'

RSpec.describe Magic::Cards::SwiftResponse do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  let(:swift_response) { Card("Swift Response") }

  it "destroys the wood elves" do
    wood_elves.tap!
    p1.add_mana(white: 2)
    action = cast_action(player: p1, card: swift_response)
    action.pay_mana(generic: { white: 1 }, white: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.stack.resolve!
    expect(wood_elves).to be_dead
  end
end
