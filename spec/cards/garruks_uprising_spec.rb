# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GarruksUprising do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_uprising
    card = Card("Garruks Uprising", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "draws a card when it enters if you control a creature with power 4 or greater" do
    ResolvePermanent("Garruks Gorehorn", owner: p1)
    hand_size = p1.hand.count

    cast_uprising

    expect(p1.hand.count).to eq(hand_size + 1) # Uprising added then cast, plus one drawn
  end

  it "does not draw when it enters without a creature with power 4 or greater" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    library_count = p1.library.count

    cast_uprising

    expect(p1.library.count).to eq(library_count)
  end

  context "once on the battlefield" do
    let!(:uprising) { ResolvePermanent("Garruks Uprising", owner: p1) }

    it "gives your creatures trample, but not your opponent's" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      game.tick!

      expect(mine.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
      expect(theirs.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(false)
    end

    it "draws when a creature with power 4 or greater enters under your control" do
      library_count = p1.library.count
      ResolvePermanent("Garruks Gorehorn", owner: p1)

      expect(p1.library.count).to eq(library_count - 1)
    end

    it "does not draw for a smaller creature or an opponent's creature" do
      library_count = p1.library.count
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Garruks Gorehorn", owner: p2)

      expect(p1.library.count).to eq(library_count)
    end
  end
end
