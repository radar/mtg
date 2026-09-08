require "spec_helper"

RSpec.describe Magic::Cards::NecroblossomSnarl do
  include_context "two player game"

  it "enters tapped without a Swamp or Forest in hand" do
    p1.hand.items.clear
    permanent = play_land(Card("Necroblossom Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters untapped with a Forest in hand" do
    p1.hand.add(Card("Forest", owner: p1))
    permanent = play_land(Card("Necroblossom Snarl"))

    expect(permanent).not_to be_tapped
  end

  it "taps for black or green" do
    permanent = play_land(Card("Necroblossom Snarl"))

    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
  end

  private

  def play_land(card)
    p1.play_land(land: card)
    p1.permanents.by_name(card.name).first
  end
end