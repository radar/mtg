# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlickACoin do
  include_context "two player game"

  it "deals 1 damage to any target, creates a Treasure token, and draws a card" do
    library_count_before = p1.library.count

    p1.add_mana(generic: 2, red: 1)
    cast_action(player: p1, card: Card("Flick A Coin", owner: p1))
      .pay_mana(generic: { generic: 2 }, red: 1)
      .targeting(p2)
      .perform
    game.stack.resolve!
    game.tick!

    expect(p2.life).to eq(19)
    treasure = p1.permanents.by_name("Treasure").first
    expect(treasure).not_to be_nil
    expect(p1.library.count).to eq(library_count_before - 1)
  end
end
