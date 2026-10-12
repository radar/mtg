# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrivingHeath do
  include_context "two player game"

  let!(:heath) { ResolvePermanent("Thriving Heath", owner: p1) }

  it "enters tapped and asks for a colour" do
    expect(heath).to be_tapped
    expect(game.choices.last).to be_a(described_class::ColorChoice)
  end

  it "does not allow white as the chosen colour" do
    expect { game.resolve_choice!(color: :white) }.to raise_error(/Invalid color/)
  end

  it "taps for white or the chosen colour" do
    heath.untap!
    game.resolve_choice!(color: :green)

    p1.activate_ability(ability: heath.activated_abilities.first) { |a| a.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)

    heath.untap!
    p1.activate_ability(ability: heath.activated_abilities.first) { |a| a.choose(:white) }
    expect(p1.mana_pool[:white]).to eq(1)
  end
end
