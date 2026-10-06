# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Transmogrify do
  include_context "two player game"
  before { go_to_main_phase! }

  def p2_library
    [Card("Forest"), Card("Island"), Card("Serra Angel"), Card("Forest"), Card("Forest"), Card("Forest"), Card("Forest"),
     Card("Forest"), Card("Forest"), Card("Forest")]
  end

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast(target)
    card = Card("Transmogrify", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 4)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 3 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "exiles the target creature" do
    cast(bears)

    expect(game.exile.cards).to include(bears.card)
  end

  it "puts the first creature card from the top of its controller's library onto the battlefield" do
    p2.library.add(Card("Serra Angel", owner: p2))
    cast(bears)

    expect(p2.creatures.map(&:name)).to eq(["Serra Angel"])
  end

  it "keeps the other revealed cards in the library" do
    library_count = p2.library.count
    p2.library.add(Card("Serra Angel", owner: p2))
    cast(bears)

    expect(p2.library.count).to eq(library_count)
  end

  it "works on your own creature, giving you the replacement" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.library.add(Card("Serra Angel", owner: p1))
    cast(mine)

    expect(p1.creatures.map(&:name)).to eq(["Serra Angel"])
  end
end
