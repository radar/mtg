# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodlineBidding do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:elf) { Card("Llanowar Elves", owner: p1) }
  let(:other_elf) { Card("Llanowar Elves", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:opponents_elf) { Card("Llanowar Elves", owner: p2) }
  let(:spell) { Card("Bloodline Bidding", owner: p1) }

  it "has convoke" do
    expect(spell.convoke?).to eq(true)
  end

  it "returns all creature cards of the chosen type from your graveyard to the battlefield" do
    [elf, other_elf, bears].each { |card| p1.graveyard.add(card) }
    p2.graveyard.add(opponents_elf)
    p1.hand.add(spell)
    p1.add_mana(black: 8)
    cast_and_resolve(card: spell, player: p1) { |a| a.pay_mana(generic: { black: 6 }, black: 2) }

    game.resolve_choice!(creature_type: "Elf")

    expect(elf.zone).to be_a(Magic::Zones::Battlefield)
    expect(other_elf.zone).to be_a(Magic::Zones::Battlefield)
    expect(bears.zone).to eq(p1.graveyard)
    expect(opponents_elf.zone).to eq(p2.graveyard)
  end
end
