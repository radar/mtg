# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiseOfTheWitchKing do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:mine2) { ResolvePermanent("Raging Goblin", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:theirs2) { ResolvePermanent("Raging Goblin", owner: p2) }
  let(:forest) { Card("Forest", owner: p1) }
  let(:bolt) { Card("Lightning Bolt", owner: p1) }

  before do
    go_to_main_phase!
    p1.graveyard.add(forest)
    p1.graveyard.add(bolt)
  end

  def cast_it
    p1.add_mana(black: 2, green: 2)
    p1.cast(card: Card("Rise Of The Witch King", owner: p1)) do
      _1.pay_mana(black: 1, green: 1, generic: { black: 1, green: 1 })
    end
    game.stack.resolve!
  end

  # Caster sacrifices `mine`, declines the return, opponent sacrifices `theirs`.
  def sacrifice_both
    cast_it
    game.resolve_choice!(target: mine)
    game.skip_choice!
    game.resolve_choice!(target: theirs)
  end

  it "makes each player sacrifice a creature of their choice" do
    sacrifice_both

    expect(p1.creatures).to eq([mine2])
    expect(p2.creatures).to eq([theirs2])
  end

  it "returns another permanent card from your graveyard after you sacrificed a creature" do
    cast_it
    game.resolve_choice!(target: mine)
    game.resolve_choice!(card: forest)
    game.settle!

    expect(p1.lands.map(&:card)).to include(forest)
    expect(p1.graveyard.cards).not_to include(forest)
  end

  it "offers the other permanent card but not the sacrificed creature, nor a nonpermanent card" do
    cast_it
    game.resolve_choice!(target: mine)

    expect(game.choices.first.choices).to eq([forest])
    expect { game.resolve_choice!(card: bolt) }.to raise_error(ArgumentError)
    expect { game.resolve_choice!(card: mine.card) }.to raise_error(ArgumentError)
  end

  it "may decline to return anything" do
    sacrifice_both
    game.settle!

    expect(p1.graveyard.cards).to include(forest)
    expect(p1.lands.map(&:card)).not_to include(forest)
  end

  it "offers no return when nothing else is in the graveyard" do
    p1.graveyard.cards.to_a.dup.each { p1.graveyard.remove(_1) }
    cast_it
    game.resolve_choice!(target: mine)

    expect(game.choices.size).to eq(1)
    expect(game.choices.first.chooser).to eq(p2)
  end

  it "does not return anything if you had no creature to sacrifice" do
    mine.sacrifice!
    mine2.sacrifice!
    game.settle!
    cast_it
    game.resolve_choice!(target: theirs)

    expect(game.choices).to be_empty
    expect(p1.lands.map(&:card)).not_to include(forest)
    expect(p2.creatures).to eq([theirs2])
  end

  it "makes the sacrifice mandatory" do
    cast_it
    game.skip_choice!
    game.skip_choice!
    game.skip_choice!

    expect(p1.creatures.size).to eq(1)
    expect(p2.creatures.size).to eq(1)
  end
end
