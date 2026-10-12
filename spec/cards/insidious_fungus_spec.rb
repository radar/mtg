# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InsidiousFungus do
  include_context "two player game"

  let!(:fungus) { ResolvePermanent("Insidious Fungus", owner: p1) }

  def activate!
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: fungus.activated_abilities.first) { |a| a.pay_mana(generic: { colorless: 2 }) }
    game.settle!
  end

  it "is a 1/2" do
    expect(fungus.power).to eq(1)
    expect(fungus.toughness).to eq(2)
  end

  it "sacrifices itself and can destroy an artifact" do
    ResolvePermanent("Sol Ring", owner: p2)
    activate!
    game.resolve_choice!(mode: :artifact)
    game.resolve_choice!(target: p2.permanents.by_any_type("Artifact").first) if game.choices.any?
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Insidious Fungus")
    expect(game.battlefield.permanents.by_any_type("Artifact")).to be_empty
  end

  it "can draw a card, then put a land from hand onto the battlefield tapped" do
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    activate!
    hand_before = p1.hand.count
    game.resolve_choice!(mode: :draw)
    expect(p1.hand.count).to eq(hand_before + 1)
    game.resolve_choice!(target: land)
    game.settle!

    expect(p1.lands.map(&:name)).to include("Forest")
    expect(p1.lands.find { _1.card == land }).to be_tapped
  end
end
