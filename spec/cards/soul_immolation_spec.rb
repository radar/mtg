# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoulImmolation do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Soul Immolation", owner: p1) }
  let!(:mine) { ResolvePermanent("Courser Of Kruphix", owner: p1) } # 2/4

  def cast(x)
    p1.hand.add(card)
    p1.add_mana(red: 5)
    p1.cast(card:) { _1.pay_mana(generic: { red: 3 }, red: 2).pay_blight_x(mine, x) }
    game.stack.resolve!
    game.settle!
  end

  it "blights X, then deals X damage to each opponent and each creature they control" do
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast(3)

    expect(mine.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(3)
    expect(p2.life).to eq(17)
    expect(theirs.damage).to eq(3)
  end

  it "doesn't damage you or your creatures" do
    cast(2)

    expect(p1.life).to eq(20)
    expect(mine.damage).to eq(0)
  end

  it "can't blight more than the greatest toughness among your creatures" do
    p1.hand.add(card)
    p1.add_mana(red: 5)

    expect { p1.cast(card:) { _1.pay_mana(generic: { red: 3 }, red: 2).pay_blight_x(mine, 5) } }.to raise_error(/between 0 and 4/)
  end

  it "X = 0 does nothing but resolve" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    cast(0)

    expect(p2.life).to eq(20)
  end

  it "can't be cast without paying the additional cost" do
    p1.hand.add(card)
    p1.add_mana(red: 5)

    expect { p1.cast(card:) { _1.pay_mana(generic: { red: 3 }, red: 2) } }.to raise_error(/Additional costs/)
  end

  it "blights a creature you choose" do
    other = ResolvePermanent("Courser Of Kruphix", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 5)
    p1.cast(card:) { _1.pay_mana(generic: { red: 3 }, red: 2).pay_blight_x(other, 1) }

    expect(other.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(mine.counters.of_type(Magic::Counters::Minus1Minus1)).to be_empty
  end
end
