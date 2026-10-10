# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CacklingSlasher do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_slasher
    card = Card("Cackling Slasher", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 4)
    p1.cast(card:) { _1.pay_mana(generic: { black: 3 }, black: 1) }
    game.stack.resolve!
    game.settle!
    p1.creatures.find { _1.name == "Cackling Slasher" }
  end

  it "has deathtouch" do
    expect(cast_slasher).to be_deathtouch
  end

  it "enters as a 3/3 when no creature died this turn" do
    slasher = cast_slasher
    expect(slasher.power).to eq(3)
    expect(slasher.toughness).to eq(3)
  end

  it "enters with a +1/+1 counter if a creature died this turn" do
    ResolvePermanent("Wood Elves", owner: p2).sacrifice!
    game.settle!
    slasher = cast_slasher
    expect(slasher.power).to eq(4)
    expect(slasher.toughness).to eq(4)
  end
end
