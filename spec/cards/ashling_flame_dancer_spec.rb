# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AshlingFlameDancer do
  include_context "two player game"

  let!(:ashling) { ResolvePermanent("Ashling Flame Dancer", owner: p1) }

  before { go_to_main_phase! }

  def cast_shock!
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.settle!
  end

  def magecraft!
    cast_shock!
    game.stack.resolve!
    game.resolve_choice!(card: p1.hand.cards.first) if game.choices.any?
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4" do
    expect([ashling.power, ashling.toughness]).to eq([4, 4])
  end

  it "discards a card then draws a card when an instant is cast" do
    hand_before = p1.hand.cards.size
    magecraft!
    expect(p1.hand.cards.size).to eq(hand_before)
    expect(p1.graveyard.cards.size).to eq(2)
  end

  it "deals 2 damage to each opponent and their creatures the second time" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    2.times { magecraft! }

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p2.life).to eq(20 - 2 - 2 - 2)
  end

  it "adds RRRR the third time" do
    3.times { magecraft! }
    expect(p1.mana_pool[:red]).to eq(4)
  end

  it "triggers when an instant spell is copied" do
    Magic::CopyEffect.resolve_with_choice!(actor: Card("Shock", owner: p1), receiver: Card("Shock", owner: p1), targets: [p2])
    game.settle!

    expect(game.current_turn.events.any? { _1.is_a?(Magic::Events::SpellCopied) }).to be(true)
    game.skip_choice!
    game.settle!
    game.stack.resolve!

    expect(game.choices.any? { _1.is_a?(Magic::Cards::AshlingFlameDancer::DiscardThenDraw) }).to be(true)
  end

  it "does not trigger on a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    expect(game.choices).to be_empty
  end
end
