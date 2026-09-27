# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImpoliteEntrance do
  include_context "two player game"
  before { go_to_main_phase! }

  it "gives target creature trample and haste until end of turn, then draws a card" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 1)
    library_count = p1.library.count

    p1.cast(card: Card("Impolite Entrance", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.trample?).to be(true)
    expect(bears.haste?).to be(true)
    expect(p1.library.count).to eq(library_count - 1)
  end
end
