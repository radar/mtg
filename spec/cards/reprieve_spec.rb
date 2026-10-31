# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Reprieve do
  include_context "two player game"
  before { go_to_main_phase_for!(p2) }

  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:reprieve) { Card("Reprieve", owner: p1) }

  def cast_bears
    p2.hand.add(bears)
    p2.add_mana(green: 2)
    p2.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
  end

  def cast_reprieve(target)
    p1.hand.add(reprieve)
    p1.add_mana(white: 2)
    p1.cast(card: reprieve) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
  end

  it "returns target spell to its owner's hand instead of resolving" do
    spell = cast_bears
    cast_reprieve(spell)
    game.stack.resolve!
    game.settle!

    expect(bears.zone).to be_hand
    expect(p2.hand.cards).to include(bears)
    expect(p2.creatures).to be_empty
    expect(game.stack.spells).to be_empty
    expect(reprieve.zone).to be_graveyard
  end

  it "draws a card" do
    spell = cast_bears
    cast_reprieve(spell)
    hand = p1.hand.count
    library = p1.library.count
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand + 1)
    expect(p1.library.count).to eq(library - 1)
  end

  it "can't target itself" do
    spell = cast_bears
    cast_reprieve(spell)

    expect(reprieve.target_choices.map(&:card)).not_to include(reprieve)
  end
end
