# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FurycalmSnarl do
  include_context "two player game"
  before { go_to_main_phase! }

  def play_land(card)
    p1.play_land(land: card)
    game.settle!
    p1.permanents.by_name(card.name).first
  end

  it "enters tapped, with no choice, when no Mountain or Plains is in hand" do
    p1.hand.items.clear
    p1.hand.add(Card("Forest", owner: p1))
    permanent = play_land(Card("Furycalm Snarl"))

    expect(permanent).to be_tapped
    expect(game.choices).to be_empty
  end

  it "enters tapped when declining to reveal" do
    p1.hand.items.clear
    p1.hand.add(Card("Mountain", owner: p1))
    permanent = play_land(Card("Furycalm Snarl"))
    game.skip_choice!

    expect(permanent).to be_tapped
  end

  it "enters untapped when revealing a Mountain" do
    mountain = Card("Mountain", owner: p1)
    p1.hand.items.clear
    p1.hand.add(mountain)
    permanent = play_land(Card("Furycalm Snarl"))
    game.resolve_choice!
    game.resolve_choice!(target: mountain)

    expect(permanent).not_to be_tapped
  end

  it "enters untapped when revealing a Plains" do
    plains = Card("Plains", owner: p1)
    p1.hand.items.clear
    p1.hand.add(plains)
    permanent = play_land(Card("Furycalm Snarl"))
    game.resolve_choice!
    game.resolve_choice!(target: plains)

    expect(permanent).not_to be_tapped
  end

  it "taps for red or white" do
    p1.hand.items.clear
    permanent = play_land(Card("Furycalm Snarl"))
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
  end
end
