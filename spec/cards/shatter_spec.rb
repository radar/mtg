require 'spec_helper'

RSpec.describe Magic::Cards::Shatter do
  include_context "two player game"

  let(:great_furnace) { ResolvePermanent("Great Furnace", controller: p1) }
  let(:card) { described_class.new(game: game) }

  it "destroys the great furnace" do
    p1.add_mana(red: 2)
    action = cast_action(player: p1, card: card)
      .pay_mana(generic: { red: 1 }, red: 1)
      .targeting(great_furnace)
    add_to_stack_and_resolve(action)
    expect(great_furnace.zone).to be_graveyard
  end
end
