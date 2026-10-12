# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RageIntoTheValley do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_rage
    card = Card("Rage Into The Valley", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def armies = p1.creatures.select { _1.type?("Army") }

  it "draws a card and loses 1 life" do
    hand = p1.hand.count
    cast_rage

    expect(p1.hand.count).to eq(hand + 1) # Rage added to hand (+1), cast (-1), draw (+1)
    expect(p1.life).to eq(19)
  end

  it "creates a 0/0 Goblin Army with two +1/+1 counters if you control no Army" do
    cast_rage

    expect(armies.count).to eq(1)
    expect(armies.first.type?("Goblin")).to be(true)
    expect([armies.first.power, armies.first.toughness]).to eq([2, 2])
  end

  it "adds to your existing Army instead of making another" do
    cast_rage
    cast_rage

    expect(armies.count).to eq(1)
    expect(armies.first.power).to eq(4)
  end
end
