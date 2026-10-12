# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CantankerousKeepers do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_keepers(mana)
    p1.add_mana(**mana)
    p1.cast(card: Card("Cantankerous Keepers", owner: p1)) { |a| a.pay_mana(**yield) }
    game.stack.resolve!
    game.settle!
  end

  it "costs {1} less for each Elf you control" do
    ResolvePermanent("Wood Elves", owner: p1)
    ResolvePermanent("Wood Elves", owner: p1)

    cast_keepers(green: 4) { { green: 1, generic: { green: 3 } } }

    expect(p1.creatures.map(&:name)).to include("Cantankerous Keepers")
  end

  it "mills four cards and puts the Elf cards from among them into your hand" do
    elf_a = Card("Wood Elves", owner: p1)
    elf_b = Card("Wood Elves", owner: p1)
    bears = Card("Grizzly Bears", owner: p1)
    other = Card("Forest", owner: p1)
    [other, bears, elf_b, elf_a].each { p1.library.add(_1) }
    hand = p1.hand.count

    cast_keepers(green: 6) { { green: 1, generic: { green: 5 } } }

    expect(p1.hand.count).to eq(hand + 2)
    expect([elf_a.zone, elf_b.zone]).to all(be_hand)
    expect(bears.zone).to be_graveyard
    expect(other.zone).to be_graveyard
  end
end
