# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Boltwave do
  include_context "two player game"
  before { go_to_main_phase! }

  it "deals 3 damage to each opponent" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(20)
  end
end
