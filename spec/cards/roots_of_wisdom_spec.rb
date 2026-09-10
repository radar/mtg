# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RootsOfWisdom do
  include_context "two player game"

  def p1_library
    14.times.map { Card("Grizzly Bears") }
  end

  it "mills three cards" do
    spell = Card("Roots Of Wisdom", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
    end.to change { p1.graveyard.count }.by_at_least(3)
  end

  it "returns a land card from the graveyard to hand when one is available" do
    forest = Card("Forest", owner: p1)
    p1.graveyard.add(forest)

    spell = Card("Roots Of Wisdom", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(described_class::ReturnChoice)
    expect(choice.choices).to include(forest)

    game.resolve_choice!(target: forest)
    expect(forest.zone).to be_hand
  end

  it "returns an Elf card from the graveyard to hand when one is available" do
    elf = Card("Llanowar Elves", owner: p1)
    p1.graveyard.add(elf)

    spell = Card("Roots Of Wisdom", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    game.resolve_choice!(target: elf)
    expect(elf.zone).to be_hand
  end

  it "draws a card instead when there is no land or Elf card in the graveyard" do
    spell = Card("Roots Of Wisdom", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    draws_before = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    draws_after = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    expect(draws_after - draws_before).to eq(1)
    expect(game.choices).to be_empty
  end
end
