require "spec_helper"

RSpec.describe Magic::Cards::StarfieldMystic do
  include_context "two player game"

  it "gets a counter when your enchantment enters the graveyard" do
    mystic = ResolvePermanent("Starfield Mystic", owner: p1)
    enchantment = ResolvePermanent("Spirited Companion", owner: p1)
    enchantment.destroy!
    game.settle!

    expect(mystic.counters.count).to eq(1)
  end
end