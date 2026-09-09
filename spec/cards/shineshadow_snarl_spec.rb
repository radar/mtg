# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShineshadowSnarl do
  include_context "two player game"

  it "enters tapped without a Plains or Swamp in hand" do
    permanent = play_land(Card("Shineshadow Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters tapped with a Plains in hand if not revealed" do
    p1.hand.add(Card("Plains", owner: p1))
    permanent = play_land(Card("Shineshadow Snarl"))

    expect(permanent).to be_tapped
  end

  it "enters untapped when revealing a Plains in hand" do
    plains = Card("Plains", owner: p1)
    p1.hand.add(plains)
    permanent = play_land(Card("Shineshadow Snarl"), reveal: plains)

    expect(permanent).not_to be_tapped
  end

  it "fires a CardsRevealed event when revealing" do
    plains = Card("Plains", owner: p1)
    p1.hand.add(plains)
    play_land(Card("Shineshadow Snarl"), reveal: plains)

    revealed_event = game.current_turn.events.find { |e| e.is_a?(Magic::Events::CardsRevealed) }
    expect(revealed_event).not_to be_nil
    expect(revealed_event.cards).to include(plains)
  end

  it "enters untapped when revealing a Swamp in hand via block" do
    swamp = Card("Swamp", owner: p1)
    p1.hand.add(swamp)
    permanent = play_land(Card("Shineshadow Snarl")) do |action|
      action.reveal(swamp)
    end

    expect(permanent).not_to be_tapped
  end

  it "enters tapped when revealing a Forest" do
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    permanent = play_land(Card("Shineshadow Snarl"), reveal: forest)

    expect(permanent).to be_tapped
  end

  it "taps for white or black" do
    permanent = play_land(Card("Shineshadow Snarl"))

    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }

    expect(p1.mana_pool[:white]).to eq(1)
  end

  private

  def play_land(card, **args, &block)
    p1.play_land(land: card, **args, &block)
    p1.permanents.by_name(card.name).first
  end
end