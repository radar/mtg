# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GuardianOfTheHalls do
  include_context "two player game"

  subject(:guardian) { ResolvePermanent("Guardian Of The Halls", owner: p1) }

  it "is a 2/2 with trample" do
    expect(guardian.power).to eq(2)
    expect(guardian.trample?).to eq(true)
  end

  it "puts three +1/+1 counters on itself for {5}{G}{G}" do
    p1.add_mana(green: 7)
    p1.activate_ability(ability: guardian.activated_abilities.first) { |a| a.pay_mana(generic: { green: 5 }, green: 2) }
    game.stack.resolve!
    expect(guardian.power).to eq(5)
    expect(guardian.toughness).to eq(5)
  end
end
