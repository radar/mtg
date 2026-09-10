# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BountyOfSkemfar do
  include_context "two player game"

  let(:elf) { Card("Elvish Mystic", owner: p1) }

  before do
    p1.library.add(elf)
  end

  it "reveals the top six cards of the library" do
    top_six = p1.library.first(6)
    spell = Card("Bounty of Skemfar", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(described_class::Choice)
    expect(top_six.all?(&:revealed?)).to eq(true)
  end

  it "offers up to one land and up to one Elf card as choices" do
    spell = Card("Bounty of Skemfar", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice.elf_choices).to include(elf)
    expect(choice.land_choices).not_to be_empty
  end

  it "puts the chosen land onto the battlefield tapped and the chosen Elf into hand, and shuffles the rest to the bottom" do
    spell = Card("Bounty of Skemfar", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    land = choice.land_choices.first
    other_cards = choice.revealed - [land, elf]
    library_size_before = p1.library.count

    game.resolve_choice!(land: land, elf: elf)

    expect(land.zone).to be_battlefield
    expect(game.battlefield.by_card(land).first).to be_tapped
    expect(p1.hand).to include(elf)
    expect(p1.library.count).to eq(library_size_before - 2)
    other_cards.each { |card| expect(p1.library).to include(card) }
  end
end
