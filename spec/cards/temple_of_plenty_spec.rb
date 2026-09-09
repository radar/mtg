require "spec_helper"

RSpec.describe Magic::Cards::TempleOfPlenty do
  include_context "two player game"

  it "enters tapped and triggers scry 1" do
    temple = ResolvePermanent("Temple of Plenty", owner: p1)

    expect(temple).to be_tapped
    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end
end