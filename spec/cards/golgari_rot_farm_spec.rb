# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GolgariRotFarm do
  include_context "two player game"

  let!(:forest) { ResolvePermanent("Forest", owner: p1) }
  let!(:farm) do
    ResolvePermanent("Golgari Rot Farm", owner: p1).tap { game.resolve_choice!(target: forest) }
  end

  it "enters tapped and returns a land to its owner's hand" do
    expect(farm).to be_tapped
    expect(p1.hand.by_name("Forest").count).to eq(8)
  end

  it "can return itself" do
    expect(p1.permanents.by_name("Forest")).to be_empty
    expect(p1.permanents.by_name("Golgari Rot Farm")).not_to be_empty
  end

  it "taps for {B}{G}" do
    farm.untap!
    p1.activate_ability(ability: farm.activated_abilities.first)
    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.mana_pool[:green]).to eq(1)
  end
end
