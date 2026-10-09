# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DesolationOfSmaug do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:dragon) { ResolvePermanent("Firespitter Whelp", owner: p2) }
  let!(:theirs) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_desolation
    p1.add_mana(red: 4)
    p1.cast(card: Card("Desolation Of Smaug", owner: p1)) { _1.pay_mana(red: 2, generic: { red: 2 }) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 3 damage to each non-Dragon creature, whoever controls it" do
    cast_desolation

    expect(mine.zone).to be_nil
    expect(theirs.zone).to be_nil
    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p2.graveyard.cards.map(&:name)).to include("Wood Elves")
  end

  it "doesn't hurt Dragons" do
    cast_desolation

    expect(dragon.damage).to eq(0)
    expect(p2.creatures).to include(dragon)
  end

  it "adds four mana of the chosen colors that can only be spent on Dragon spells" do
    cast_desolation
    game.resolve_choice!(mana: { red: 2, black: 2 })

    dragon_spell = Card("Firespitter Whelp", owner: p1)
    other_spell = Card("Grizzly Bears", owner: p1)
    expect(p1.restricted_mana_for(dragon_spell)).to eq(red: 2, black: 2)
    expect(p1.restricted_mana_for(other_spell)).to be_empty
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "defaults to four red mana" do
    cast_desolation
    game.resolve_choice!

    expect(p1.restricted_mana_for(Card("Firespitter Whelp", owner: p1))).to eq(red: 4)
  end

  it "requires exactly four mana" do
    cast_desolation

    expect { game.resolve_choice!(mana: { red: 3 }) }.to raise_error(ArgumentError)
  end
end
