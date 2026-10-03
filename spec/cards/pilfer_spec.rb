# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Pilfer do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Pilfer", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }

  def set_hand(player, *cards)
    [*player.hand.cards].each { player.hand.remove(_1) }
    cards.each { player.hand.add(_1) }
  end

  def cast_pilfer
    p1.add_mana(black: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(p2) }
    game.stack.resolve!
  end

  it "lets you choose any nonland card, creatures included" do
    set_hand(p2, bears, forest)
    cast_pilfer

    expect(game.choices.last.choices).to eq([bears])
    game.resolve_choice!(card: bears)
    expect(p2.graveyard.cards).to include(bears)
    expect(p2.hand.cards).to eq([forest])
  end

  it "does not let you choose a land" do
    set_hand(p2, bears, forest)
    cast_pilfer

    expect { game.choices.last.resolve!(card: forest) }.to raise_error(ArgumentError)
    expect(p2.hand.cards).to include(forest)
  end

  it "asks nothing when the hand is only lands" do
    set_hand(p2, forest)
    cast_pilfer

    expect(game.choices).to be_empty
  end
end
