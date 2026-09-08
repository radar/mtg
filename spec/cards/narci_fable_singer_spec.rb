require "spec_helper"

RSpec.describe Magic::Cards::NarciFableSinger do
  include_context "two player game"

  it "draws a card when you sacrifice an enchantment" do
    ResolvePermanent("Narci, Fable Singer", owner: p1)
    enchantment = ResolvePermanent("Spirited Companion", owner: p1)
    hand_size = p1.hand.count
    enchantment.sacrifice!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end