# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PriestOfTitania do
  include_context "two player game"

  subject!(:priest) { ResolvePermanent("Priest of Titania", owner: p1) }

  def activate_ability
    p1.activate_ability(ability: priest.activated_abilities.first)
  end

  it "adds one green mana for itself when it's the only Elf" do
    activate_ability

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "adds green mana for each Elf on the battlefield, including opponents'" do
    ResolvePermanent("Elvish Warmaster", owner: p1)
    ResolvePermanent("Elvish Warmaster", owner: p2)

    activate_ability

    expect(p1.mana_pool[:green]).to eq(3)
  end

  it "does not count non-Elf creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    activate_ability

    expect(p1.mana_pool[:green]).to eq(1)
  end
end
