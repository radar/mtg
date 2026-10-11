# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeechriddenSwamp do
  include_context "two player game"

  let!(:swamp) { ResolvePermanent("Leechridden Swamp", owner: p1) }

  before { swamp.untap! }

  def drain
    ability = swamp.activated_abilities.find { _1.class.name.to_s.include?("DrainAbility") }
    p1.add_mana(black: 1)
    p1.activate_ability(ability: ability) { _1.pay_mana(black: 1) }
    game.stack.resolve!
  end

  it "enters tapped and is a Swamp" do
    expect(ResolvePermanent("Leechridden Swamp", owner: p1)).to be_tapped
    expect(swamp.type?("Swamp")).to be(true)
  end

  it "makes each opponent lose 1 life with two or more black permanents" do
    ResolvePermanent("Baneslayer Angel", owner: p1) # white, not black
    2.times { ResolvePermanent("Shroudstomper", owner: p1) } # white and black
    life = p2.life

    drain

    expect(p2.life).to eq(life - 1)
  end

  it "can't be activated with fewer than two black permanents" do
    ability = swamp.activated_abilities.find { _1.class.name.to_s.include?("DrainAbility") }

    expect(ability).not_to be_requirements_met
  end
end
