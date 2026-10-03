# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeroesBane do
  include_context "two player game"

  let!(:bane) { ResolvePermanent("Heroes' Bane", owner: p1) }

  def counters = bane.counters.of_type(Magic::Counters["+1/+1"]).count

  it "enters with four +1/+1 counters, so it is a 4/4" do
    game.tick!

    expect(counters).to eq(4)
    expect([bane.power, bane.toughness]).to eq([4, 4])
  end

  it "puts X +1/+1 counters on itself for {2}{G}{G}, X being its power" do
    p1.add_mana(green: 4)
    p1.activate_ability(ability: bane.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }, green: 2) }
    game.stack.resolve!
    game.tick!

    expect(counters).to eq(8)
    expect([bane.power, bane.toughness]).to eq([8, 8])
  end

  it "doubles again the next time" do
    2.times do
      p1.add_mana(green: 4)
      p1.activate_ability(ability: bane.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }, green: 2) }
      game.stack.resolve!
      game.tick!
    end

    expect(bane.power).to eq(16)
  end
end
