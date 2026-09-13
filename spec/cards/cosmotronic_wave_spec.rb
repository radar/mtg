# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CosmotronicWave do
  include_context "two player game"

  it "deals 1 damage to each creature your opponents control and stops them from blocking this turn" do
    opponent_bear = ResolvePermanent("Grizzly Bears", owner: p2)
    your_bear = ResolvePermanent("Grizzly Bears", owner: p1)

    p1.add_mana(generic: 3, red: 1)
    cast_action(player: p1, card: Card("Cosmotronic Wave", owner: p1))
      .pay_mana(generic: { generic: 3 }, red: 1)
      .perform
    game.stack.resolve!
    game.tick!

    expect(opponent_bear.damage).to eq(1)
    expect(opponent_bear.can_block?(your_bear)).to eq(false)
    expect(your_bear.damage).to eq(0)
    expect(your_bear.can_block?(opponent_bear)).to eq(true)
  end
end
