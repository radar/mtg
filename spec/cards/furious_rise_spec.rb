# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FuriousRise do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rise) { ResolvePermanent("Furious Rise", owner: p1) }

  def end_turn
    current_turn.end!
    game.settle!
  end

  it "does nothing at your end step without a creature with power 4 or greater" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    library_count = p1.library.count
    end_turn

    expect(p1.library.count).to eq(library_count)
    expect(rise.exiled_cards).to be_empty
  end

  it "exiles the top card of your library at your end step if you control a creature with power 4 or greater" do
    ResolvePermanent("Baneslayer Angel", owner: p1)
    top = Card("Mountain", owner: p1)
    p1.library.add(top)
    end_turn

    expect(top.zone).to be_exile
    expect(rise.exiled_cards).to eq([top])
  end

  it "lets you play the exiled card" do
    ResolvePermanent("Baneslayer Angel", owner: p1)
    top = Card("Mountain", owner: p1)
    p1.library.add(top)
    end_turn
    game.next_turn
    game.next_turn
    go_to_main_phase!

    p1.play_land(land: top)

    expect(top.zone).to be_battlefield
  end

  it "stops letting you play the previous card once another is exiled" do
    ResolvePermanent("Baneslayer Angel", owner: p1)
    first = Card("Mountain", owner: p1)
    p1.library.add(first)
    end_turn
    game.next_turn
    game.next_turn
    go_to_main_phase!
    second = Card("Forest", owner: p1)
    p1.library.add(second)
    end_turn

    expect(rise.exiled_cards.to_a).to eq([second])
    expect { p1.play_land(land: first) }.to raise_error(StandardError)
  end
end
