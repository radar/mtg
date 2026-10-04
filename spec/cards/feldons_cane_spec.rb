# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FeldonsCane do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:cane) { ResolvePermanent("Feldons Cane", owner: p1) }
  let(:mine) { Card("Grizzly Bears", owner: p1) }
  let(:also_mine) { Card("Boltwave", owner: p1) }
  let(:theirs) { Card("Grizzly Bears", owner: p2) }

  def activate!
    p1.activate_ability(ability: cane.activated_abilities.first)
    game.settle!
  end

  it "shuffles your graveyard into your library and exiles itself" do
    p1.graveyard.add(mine)
    p1.graveyard.add(also_mine)
    library_size = p1.library.cards.count
    activate!

    expect(p1.graveyard.cards).to be_empty
    expect(p1.library.cards.count).to eq(library_size + 2)
    expect(p1.library.cards).to include(mine, also_mine)
    expect(mine.zone).to be_library
    expect(cane.card.zone).to be_exile
  end

  it "leaves the opponent's graveyard alone" do
    p2.graveyard.add(theirs)
    activate!

    expect(theirs.zone).to be_graveyard
  end

  it "needs to be untapped" do
    cane.tap!

    expect { activate! }.to raise_error(Magic::IllegalAction)
  end
end
