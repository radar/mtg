require "spec_helper"

RSpec.describe Magic::Cards::Spelunking do
  include_context "two player game"

  it "draws a card and puts a land from hand onto the battlefield" do
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    hand_size = p1.hand.count
    spelunking = ResolvePermanent("Spelunking", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
    game.resolve_choice!(target: land)

    expect(p1.lands.by_name("Forest").count).to eq(1)
    expect(spelunking).to be_enchantment
  end

  it "makes lands enter untapped" do
    ResolvePermanent("Spelunking", owner: p1)
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    p1.play_land(land: land)

    expect(p1.lands.by_name("Forest").first).to be_untapped
  end
end