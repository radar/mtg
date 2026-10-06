require 'spec_helper'

RSpec.describe Magic::Cards::MayhemDevil do
  include_context "two player game"

  let!(:devil) { ResolvePermanent("Mayhem Devil", owner: p1) }

  it "deals 1 damage to any target when a permanent is sacrificed" do
    forest = ResolvePermanent("Forest", owner: p1)
    forest.sacrifice!
    game.settle!

    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(19)
  end
end
