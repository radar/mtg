# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NecroblossomSnarl do
  include_context "two player game"

  context "without a Swamp or Forest in hand" do
    before { p1.hand.items.clear }

    it "enters tapped" do
      permanent = play_land(Card("Necroblossom Snarl"))

      expect(permanent).to be_tapped
    end

    it "does not present a reveal choice" do
      play_land(Card("Necroblossom Snarl"))

      expect(game.choices).to be_empty
    end
  end

  context "with a Forest in hand" do
    let(:forest) { Card("Forest", owner: p1) }

    before do
      p1.hand.items.clear
      p1.hand.add(forest)
    end

    it "presents a may choice to reveal a card" do
      permanent = play_land(Card("Necroblossom Snarl"))

      expect(game.choices.last).to be_a(Magic::Cards::NecroblossomSnarl::MayRevealChoice)
      expect(permanent).to be_tapped
    end

    it "enters tapped when declining to reveal" do
      permanent = play_land(Card("Necroblossom Snarl"))
      game.skip_choice!

      expect(permanent).to be_tapped
    end

    it "enters untapped when revealing the Forest" do
      permanent = play_land(Card("Necroblossom Snarl"))
      game.resolve_choice!
      game.resolve_choice!(target: forest)

      expect(permanent).not_to be_tapped
    end
  end

  context "with a Swamp in hand" do
    let(:swamp) { Card("Swamp", owner: p1) }

    before do
      p1.hand.items.clear
      p1.hand.add(swamp)
    end

    it "enters untapped when revealing the Swamp" do
      permanent = play_land(Card("Necroblossom Snarl"))
      game.resolve_choice!
      game.resolve_choice!(target: swamp)

      expect(permanent).not_to be_tapped
    end
  end

  it "taps for black or green" do
    p1.hand.items.clear
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
