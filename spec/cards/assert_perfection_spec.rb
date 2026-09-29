# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AssertPerfection do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Assert Perfection", owner: p1) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_on(*targets)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(*targets) }
    game.stack.resolve!
    game.tick!
  end

  it "gives your creature +1/+0 and has it deal damage equal to its power to their creature" do
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast_on(mine, theirs)

    expect(mine.power).to eq(3)
    expect(theirs.damage).to eq(3)
  end

  it "works with no second target (up to one)" do
    cast_on(mine)

    expect(mine.power).to eq(3)
  end

  it "cannot target an opponent's creature as the first target" do
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    p1.hand.add(card)
    p1.add_mana(green: 2)

    expect { p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(theirs) } }.to raise_error(StandardError)
  end

  it "cannot target your own creature as the second target" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)

    expect { p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(mine, other) } }.to raise_error(StandardError)
  end
end
