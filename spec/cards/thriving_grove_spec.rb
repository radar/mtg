# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrivingGrove do
  include_context "two player game"

  let!(:grove) { ResolvePermanent("Thriving Grove", owner: p1) }

  it "enters tapped" do
    expect(grove).to be_tapped
  end

  it "presents a choice to choose a color other than green" do
    choice = game.choices.last
    expect(choice).to be_a(described_class::ColorChoice)
  end

  it "taps for green or the chosen color" do
    grove.untap!
    game.resolve_choice!(color: :red)

    ability = grove.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "can tap for green regardless of the chosen color" do
    grove.untap!
    game.resolve_choice!(color: :red)

    ability = grove.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)
  end
end
