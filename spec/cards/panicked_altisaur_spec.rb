# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PanickedAltisaur do
  include_context "two player game"

  subject(:altisaur) { ResolvePermanent("Panicked Altisaur", owner: p1) }

  it "is a 4/5 Dinosaur with reach" do
    expect(altisaur.power).to eq(4)
    expect(altisaur.toughness).to eq(5)
    expect(altisaur.has_keyword?(:reach)).to eq(true)
  end

  it "deals 2 damage to each opponent when tapped" do
    ability = altisaur.activated_abilities.first
    p1.activate_ability(ability: ability)
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(altisaur.tapped?).to eq(true)
  end
end
