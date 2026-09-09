require "spec_helper"

RSpec.describe Magic::Cards::GraspOfFate do
  include_context "two player game"

  it "exiles an opponent's nonland permanent until it leaves" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    grasp = ResolvePermanent("Grasp of Fate", owner: p1)
    game.resolve_choice!(target: target)

    expect(target.card.zone).to be_exile
    grasp.destroy!

    expect(target.card.zone).to be_battlefield
  end
end