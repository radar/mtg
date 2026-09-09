# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NecroblossomSnarl do
  include_context "two player game"

  it "enters tapped without a Swamp or Forest in hand" do
    p1.hand.items.clear
    permanent = play_land(Card("Necroblossom Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters tapped with a Forest in hand if not revealed" do
    p1.hand.add(Card("Forest", owner: p1))
    permanent = play_land(Card("Necroblossom Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters untapped when revealing a Forest in hand" do
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    permanent = play_land(Card("Necroblossom Snarl"), reveal: forest)

    expect(permanent).not_to be_tapped
  end

  it "enters untapped when revealing a Swamp in hand" do
    swamp = Card("Swamp", owner: p1)
    p1.hand.add(swamp)
    permanent = play_land(Card("Necroblossom Snarl")) do |action|
      action.reveal(swamp)
    end

    expect(permanent).not_to be_tapped
  end

  it "taps for black or green" do
    permanent = play_land(Card("Necroblossom Snarl"))

    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
  end

  private

  def play_land(card, **args, &block)
    p1.play_land(land: card, **args, &block)
    p1.permanents.by_name(card.name).first
  end
end