# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RipchainRazorkin do
  include_context "two player game"

  let!(:razorkin) { ResolvePermanent("Ripchain Razorkin", owner: p1) }
  let!(:mountain) { ResolvePermanent("Mountain", owner: p1) }

  it "is a 5/3 with reach" do
    expect(razorkin.power).to eq(5)
    expect(razorkin.toughness).to eq(3)
    expect(razorkin).to have_keyword(Magic::Cards::Keywords::REACH)
  end

  it "sacrifices a land to draw a card" do
    hand_size = p1.hand.count
    p1.add_mana(red: 3)
    p1.activate_ability(ability: razorkin.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 2 }, red: 1)
      a.pay_sacrifice(mountain)
    end
    game.stack.resolve!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
    expect(mountain.zone).not_to be_a(Magic::Zones::Battlefield)
  end
end
