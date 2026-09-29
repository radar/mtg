# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DarknessDescends do
  include_context "two player game"
  before { go_to_main_phase! }

  it "puts two -1/-1 counters on each creature, yours and theirs" do
    mine = ResolvePermanent("Courser Of Kruphix", owner: p1)
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    spell = Card("Darkness Descends", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 4)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 2 }, black: 2) }
    game.stack.resolve!
    game.tick!

    expect([mine, theirs].map { [_1.power, _1.toughness] }).to all(eq([0, 2]))
    expect(mine.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "kills creatures with toughness 2 or less" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    spell = Card("Darkness Descends", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 4)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 2 }, black: 2) }
    game.stack.resolve!

    expect(bears.card.zone).to be_graveyard
  end
end
