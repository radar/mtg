# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValgavothsLair do
  include_context "two player game"

  let!(:lair) { ResolvePermanent("Valgavoth's Lair", owner: p1) }

  it "is an enchantment land with hexproof that enters tapped" do
    expect(lair.card).to be_land
    expect(lair.card).to be_enchantment
    expect(lair).to be_hexproof
    expect(lair).to be_tapped
  end

  it "can't be targeted by an opponent's spells" do
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)

    expect { p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(lair) } }.to raise_error(StandardError)
  end

  it "asks for a color as it enters" do
    expect(game.choices.last).to be_a(described_class::ColorChoice)
  end

  it "taps for mana of the chosen color" do
    game.resolve_choice!(color: :blue)
    lair.untap!

    p1.activate_ability(ability: lair.activated_abilities.first) { |a| a.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "offers only the chosen color" do
    game.resolve_choice!(color: :black)

    expect(lair.activated_abilities.first.choices).to eq([:black])
  end
end
