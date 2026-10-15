# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FaithfulWatchdog do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:dog) do
    p1.add_mana(green: 1, white: 1)
    card = Card("Faithful Watchdog", owner: p1)
    p1.hand.add(card)
    p1.cast(card: card) { _1.auto_pay_mana }
    game.stack.resolve!
    game.settle!
    p1.creatures.first
  end

  it "has vigilance" do
    expect(dog).to have_keyword(:vigilance)
  end

  it "enters with three +1/+1 counters, making it a 3/3" do
    expect(dog.counters.count).to eq(3)
    expect(dog.counters).to all(be_a(Magic::Counters::Plus1Plus1))
    expect(dog.power).to eq(3)
    expect(dog.toughness).to eq(3)
    expect(p1.creatures).to include(dog)
  end
end
