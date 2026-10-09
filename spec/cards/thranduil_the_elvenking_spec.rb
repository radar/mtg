# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThranduilTheElvenking do
  include_context "two player game"

  let!(:thranduil) { ResolvePermanent("Thranduil, The Elvenking", owner: p1) }

  def mana_abilities = thranduil.activated_abilities.select { _1.is_a?(Magic::ManaAbility) }

  it "is a 5/6" do
    expect([thranduil.power, thranduil.toughness]).to eq([5, 6])
  end

  it "has no activated abilities with no Elf cards in the graveyard" do
    game.tick!

    expect(thranduil.activated_abilities).to be_empty
  end

  it "has the activated abilities of Elf cards in your graveyard" do
    p1.graveyard.add(Card("Llanowar Elves", owner: p1))
    game.tick!
    thranduil.untap!
    mana = mana_abilities.first
    p1.activate_ability(ability: mana) if mana

    expect(mana).not_to be_nil
    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "does not use Elf cards in an opponent's graveyard" do
    p2.graveyard.add(Card("Llanowar Elves", owner: p2))
    game.tick!

    expect(thranduil.activated_abilities).to be_empty
  end

  it "draws two then discards one when another legendary Elf you control enters" do
    library_before = p1.library.count
    ResolvePermanent("Radha, Heart Of Keld", owner: p1)
    game.settle!

    expect(p1.library.count).to eq(library_before - 2)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end

  it "does not trigger for a nonlegendary Elf" do
    library_before = p1.library.count
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.settle!

    expect(p1.library.count).to eq(library_before)
  end

  it "does not trigger for an opponent's legendary Elf" do
    library_before = p1.library.count
    ResolvePermanent("Radha, Heart Of Keld", owner: p2)
    game.settle!

    expect(p1.library.count).to eq(library_before)
  end
end
