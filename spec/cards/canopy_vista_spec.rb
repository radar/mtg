require "spec_helper"

RSpec.describe Magic::Cards::CanopyVista do
  include_context "two player game"

  let(:card) { Card("Canopy Vista") }

  it "enters tapped without two basic lands" do
    permanent = play_land(card)

    expect(permanent).to be_tapped
  end

  it "enters untapped with two basic lands" do
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Plains", owner: p1)
    permanent = play_land(card)

    expect(permanent).not_to be_tapped
  end

  it "taps for green or white" do
    permanent = play_land(card)

    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }

    expect(p1.mana_pool.slice(:green, :white)).to eq(green: 1, white: 1)
  end

  private

  def play_land(card)
    p1.play_land(land: card)
    p1.permanents.by_name(card.name).first
  end
end