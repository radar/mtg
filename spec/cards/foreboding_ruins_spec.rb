# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ForebodingRuins do
  include_context "two player game"

  it "enters untapped when you reveal a Swamp or Mountain card from your hand" do
    p1.hand.add(Card("Swamp", owner: p1))

    expect(ResolvePermanent("Foreboding Ruins", owner: p1)).not_to be_tapped
  end

  it "reveals the card it used" do
    swamp = Card("Mountain", owner: p1).tap { p1.hand.add(_1) }
    ResolvePermanent("Foreboding Ruins", owner: p1)

    expect(swamp).to be_revealed
  end

  it "enters tapped when you have no Swamp or Mountain card in hand" do
    p1.hand.add(Card("Forest", owner: p1))

    expect(ResolvePermanent("Foreboding Ruins", owner: p1)).to be_tapped
  end

  it "taps for black or red" do
    land = ResolvePermanent("Foreboding Ruins", owner: p1)

    expect(land.activated_abilities.first.choices).to contain_exactly(:black, :red)
  end
end
