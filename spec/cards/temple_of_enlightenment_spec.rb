# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TempleOfEnlightenment do
  include_context "two player game"

  let!(:temple) { ResolvePermanent("Temple of Enlightenment", owner: p1) }

  it "enters tapped and scries 1" do
    expect(temple).to be_tapped
    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end

  it "taps for {W} or {U}" do
    temple.untap!
    p1.activate_ability(ability: temple.activated_abilities.first) { |a| a.choose(:white) }
    expect(p1.mana_pool[:white]).to eq(1)
  end
end
