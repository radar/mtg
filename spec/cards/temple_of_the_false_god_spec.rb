# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TempleOfTheFalseGod do
  include_context "two player game"

  let!(:temple) { ResolvePermanent("Temple Of The False God", owner: p1) }

  it "can be activated with five lands, counting itself" do
    4.times { ResolvePermanent("Forest", owner: p1) }

    expect(temple.activated_abilities.first).to be_requirements_met
  end

  it "adds {C}{C} with five or more lands" do
    4.times { ResolvePermanent("Forest", owner: p1) }
    temple.untap!
    p1.activate_ability(ability: temple.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(2)
  end

  it "does nothing with fewer than five lands" do
    3.times { ResolvePermanent("Forest", owner: p1) }

    expect(temple.activated_abilities.first).not_to be_requirements_met
  end
end
