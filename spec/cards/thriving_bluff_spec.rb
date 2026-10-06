# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrivingBluff do
  include_context "two player game"

  let!(:bluff) { ResolvePermanent("Thriving Bluff", owner: p1) }

  it "enters tapped and asks for a colour" do
    expect(bluff).to be_tapped
    expect(game.choices.last).to be_a(described_class::ColorChoice)
  end

  it "does not allow red as the chosen colour" do
    expect { game.resolve_choice!(color: :red) }.to raise_error(/Invalid color/)
  end

  it "taps for red or the chosen colour" do
    bluff.untap!
    game.resolve_choice!(color: :blue)

    p1.activate_ability(ability: bluff.activated_abilities.first) { |a| a.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)

    bluff.untap!
    p1.activate_ability(ability: bluff.activated_abilities.first) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
