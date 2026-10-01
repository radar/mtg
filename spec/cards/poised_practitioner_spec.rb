# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PoisedPractitioner do
  include_context "two player game"

  let!(:practitioner) { ResolvePermanent("Poised Practitioner", owner: p1) }

  before do
    go_to_main_phase!
    p1.add_mana(red: 4)
  end

  def cast_bolt
    card = Card("Lightning Bolt")
    p1.hand.add(card)
    p1.cast(card:) do |action|
      action.pay_mana(red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/3" do
    expect([practitioner.power, practitioner.toughness]).to eq([2, 3])
  end

  it "gets a +1/+1 counter and scries 1 on the second spell each turn" do
    cast_bolt
    expect(practitioner.power).to eq(2)
    cast_bolt
    game.tick!

    expect([practitioner.power, practitioner.toughness]).to eq([3, 4])
    expect(game.choices.first).to be_a(Magic::Choice::Scry)
  end
end
