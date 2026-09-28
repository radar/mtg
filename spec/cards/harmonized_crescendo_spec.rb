# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HarmonizedCrescendo do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Harmonized Crescendo", owner: p1) }

  it "has convoke" do
    expect(spell.convoke?).to eq(true)
  end

  it "draws a card for each permanent you control of the chosen type" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(blue: 6)
    cast_and_resolve(card: spell, player: p1) { |a| a.pay_mana(generic: { blue: 4 }, blue: 2) }
    hand_before = p1.hand.count

    game.resolve_choice!(creature_type: "Elf")

    expect(p1.hand.count).to eq(hand_before + 2)
  end
end
