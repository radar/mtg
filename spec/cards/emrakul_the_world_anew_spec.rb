# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmrakulTheWorldAnew do
  include_context "two player game"

  before { go_to_main_phase! }

  it "is a 12/12 flyer" do
    emrakul = ResolvePermanent("Emrakul, The World Anew", owner: p1)
    expect([emrakul.power, emrakul.toughness]).to eq([12, 12])
    expect(emrakul).to be_flying
  end

  it "steals the target player's creatures when cast" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    card = Card("Emrakul, The World Anew", owner: p1)
    p1.hand.add(card)
    p1.add_mana(colorless: 12)
    p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 12 }) }
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(bears.controller).to eq(p1)
  end

  it "is protected from spells" do
    emrakul = ResolvePermanent("Emrakul, The World Anew", owner: p1)
    spell = Card("Doom Blade", owner: p2)
    p2.hand.add(spell)
    p2.add_mana(black: 2)
    expect do
      p2.cast(card: spell) { |a| a.pay_mana(generic: { black: 1 }, black: 1); a.targeting(emrakul) }
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "is protected from a spell on the stack but not from a card in a graveyard" do
    emrakul = ResolvePermanent("Emrakul, The World Anew", owner: p1)
    spell = Card("Doom Blade", owner: p2)
    p2.hand.add(spell)
    p2.add_mana(black: 2)
    p2.cast(card: spell) { |a| a.pay_mana(generic: { black: 1 }, black: 1); a.targeting(ResolvePermanent("Grizzly Bears", owner: p1)) }
    expect(spell.zone).to be_stack
    expect(emrakul.protected_from?(spell)).to be(true)

    in_graveyard = Card("Doom Blade", owner: p2)
    p2.graveyard.add(in_graveyard)
    expect(emrakul.protected_from?(in_graveyard)).to be(false)
  end

  it "is protected from a permanent cast this turn" do
    emrakul = ResolvePermanent("Emrakul, The World Anew", owner: p1)
    p2.add_mana(green: 2)
    go_to_main_phase_for!(p2)
    p2.add_mana(green: 2)
    p2.cast(card: Card("Grizzly Bears", owner: p2)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    bears = p2.creatures.find { _1.name == "Grizzly Bears" }
    expect(emrakul.protected_from?(bears)).to be(true)

    game.next_turn
    expect(emrakul.protected_from?(bears)).to be(false)
  end

  it "sacrifices your creatures when it leaves the battlefield" do
    emrakul = ResolvePermanent("Emrakul, The World Anew", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    emrakul.destroy!
    game.settle!

    expect(game.battlefield.creatures.select { _1.controller == p1 }).to be_empty
    expect(other.zone).to be_battlefield
    expect(bears.zone).to be_nil
  end

  context "madness" do
    let(:card) { Card("Emrakul, The World Anew", owner: p1) }
    before { p1.hand.add(card) }

    it "goes to the graveyard when the madness cast is declined" do
      card.discard!
      expect(card.zone).to be_exile
      game.skip_choice!
      expect(card.zone).to be_graveyard
    end

    it "is cast for six colorless when discarded" do
      p1.add_mana(colorless: 6)
      card.discard!
      game.resolve_choice!
      game.settle!
      expect(card.zone).to be_battlefield.or be_stack
    end
  end
end
