# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChronicleOfVictory do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:elf) { ResolvePermanent("Llanowar Elves", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:chronicle) { ResolvePermanent("Chronicle Of Victory", owner: p1) }

  before do
    game.resolve_choice!(creature_type: "Elf")
    game.tick!
  end

  it "is legendary" do
    expect(chronicle.legendary?).to eq(true)
  end

  it "gives creatures you control of the chosen type +2/+2, first strike and trample" do
    expect(elf.power).to eq(3)
    expect(elf.toughness).to eq(3)
    expect(elf.first_strike?).to eq(true)
    expect(elf.trample?).to eq(true)
  end

  it "does not affect creatures of another type" do
    expect(bears.power).to eq(2)
    expect(bears.first_strike?).to eq(false)
  end

  it "does not affect an opponent's creature of the chosen type" do
    theirs = ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!

    expect(theirs.power).to eq(1)
  end

  it "draws a card whenever you cast a spell of the chosen type" do
    spell = Card("Llanowar Elves", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 1)
    hand_before = p1.hand.count
    p1.cast(card: spell) { |a| a.pay_mana(green: 1) }
    game.settle!

    # the spell left the hand, the trigger drew one
    expect(p1.hand.count).to eq(hand_before)
  end

  it "does not draw for a spell of another type" do
    spell = Card("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)
    hand_before = p1.hand.count
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p1.hand.count).to eq(hand_before - 1)
  end
end
