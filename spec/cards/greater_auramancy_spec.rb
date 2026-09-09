require "spec_helper"

RSpec.describe Magic::Cards::GreaterAuramancy do
  include_context "two player game"

  it "grants shroud to other enchantments you control" do
    ResolvePermanent("Greater Auramancy", owner: p1)
    enchantment = ResolvePermanent("Spirited Companion", owner: p1)
    game.tick!

    expect(enchantment).to be_shroud
  end
end