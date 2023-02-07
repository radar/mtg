require 'spec_helper'

RSpec.describe Magic::Cards::NaturesClaim do
  include_context "two player game"

  let(:great_furnace) { ResolvePermanent("Great Furnace", controller: p2) }
  let(:card) { Card("Natures Claim") }

  it "destroys the great furnace" do
    p2_starting_life = p2.life
    action = cast_action(card: card, player: p1).targeting(great_furnace)
    add_to_stack_and_resolve(action)
    expect(great_furnace.zone).to be_nil
    expect(p2.life).to eq(p2_starting_life + 4)
  end
end
