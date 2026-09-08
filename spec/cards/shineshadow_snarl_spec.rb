require "spec_helper"

RSpec.describe Magic::Cards::ShineshadowSnarl do
  include_context "two player game"

  it "enters tapped without a Plains or Swamp in hand" do
    permanent = play_land(Card("Shineshadow Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters untapped with a Plains in hand" do
    p1.hand.add(Card("Plains", owner: p1))
    permanent = play_land(Card("Shineshadow Snarl"))

    expect(permanent).not_to be_tapped
  end

  it "taps for white or black" do
    permanent = play_land(Card("Shineshadow Snarl"))

    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }

    expect(p1.mana_pool[:white]).to eq(1)
  end

  private

  def play_land(card)
    p1.play_land(land: card)
    p1.permanents.by_name(card.name).first
  end
end