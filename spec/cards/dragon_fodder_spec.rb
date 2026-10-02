# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonFodder do
  include_context "two player game"
  before { go_to_main_phase! }

  it "creates two 1/1 red Goblin creature tokens" do
    p1.add_mana(red: 2)
    p1.cast(card: Card("Dragon Fodder", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!
    goblins = p1.creatures.select { _1.name == "Goblin" }

    expect(goblins.count).to eq(2)
    expect(goblins.map { [_1.power, _1.toughness] }).to all(eq([1, 1]))
  end
end
