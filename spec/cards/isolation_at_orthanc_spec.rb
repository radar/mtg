# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IsolationAtOrthanc do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_on(target)
    p1.add_mana(blue: 4)
    p1.cast(card: Card("Isolation At Orthanc", owner: p1)) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "puts the target creature second from the top of its owner's library" do
    top = p2.library.cards.first
    size = p2.library.count
    cast_on(bears)

    expect(p2.library.cards[1]).to eq(bears.card)
    expect(p2.library.cards.first).to eq(top)
    expect(p2.library.count).to eq(size + 1)
    expect(bears.card.zone).to be_library
    expect(game.battlefield.permanents).not_to include(bears)
  end

  it "puts your own creature into your library, not the caster's" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(mine)

    expect(p1.library.cards[1]).to eq(mine.card)
  end

  it "removes a token from the game instead of putting it in the library" do
    army = Magic::Amass.call(source: bears, controller: p2, amount: 1)
    game.tick!
    size = p2.library.count
    cast_on(army)

    expect(p2.library.count).to eq(size)
    expect(p2.creatures).not_to include(army)
  end
end
