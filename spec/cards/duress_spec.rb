# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Duress do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Duress", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }
  let(:bolt) { Card("Shock", owner: p2) }

  def set_hand(player, *cards)
    [*player.hand.cards].each { player.hand.remove(_1) }
    cards.each { player.hand.add(_1) }
  end

  def cast_duress
    p1.add_mana(black: 1)
    p1.cast(card: spell) { |a| a.pay_mana(black: 1).targeting(p2) }
    game.stack.resolve!
  end

  it "costs {B} and is a sorcery" do
    expect(spell.cost.cost).to eq(black: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "reveals the opponent's hand and lets you choose a noncreature, nonland card to discard" do
    set_hand(p2, bears, forest, bolt)
    cast_duress

    expect(game.current_turn.events.find { _1.is_a?(Magic::Events::CardsRevealed) }).not_to be_nil
    choice = game.choices.last
    expect(choice.choices).to eq([bolt])
    expect { choice.resolve!(card: bears) }.to raise_error(ArgumentError)

    game.resolve_choice!(card: bolt)
    expect(p2.graveyard.cards).to include(bolt)
    expect(p2.hand.cards).to contain_exactly(bears, forest)
  end

  it "asks nothing when the hand has no noncreature, nonland card" do
    set_hand(p2, bears, forest)
    cast_duress

    expect(game.choices).to be_empty
    expect(p2.hand.cards).to contain_exactly(bears, forest)
  end

  it "only targets an opponent" do
    p1.add_mana(black: 1)
    expect { p1.cast(card: spell) { |a| a.pay_mana(black: 1).targeting(p1) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
