# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrivingMoor do
  include_context "two player game"

  let!(:moor) { ResolvePermanent("Thriving Moor", owner: p1) }

  it "enters tapped" do
    expect(moor).to be_tapped
  end

  it "presents a choice to choose a color other than black" do
    choice = game.choices.last
    expect(choice).to be_a(described_class::ColorChoice)
  end

  it "taps for black or the chosen color" do
    moor.untap!
    game.resolve_choice!(color: :red)

    ability = moor.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "can tap for black regardless of the chosen color" do
    moor.untap!
    game.resolve_choice!(color: :red)

    ability = moor.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.choose(:black) }
    expect(p1.mana_pool[:black]).to eq(1)
  end
end
