require 'spec_helper'

RSpec.describe Magic::Cards::PeerIntoTheAbyss do
  include_context "two player game"
  subject(:peer_into_the_abyss) { Card("Peer Into The Abyss") }

  it "p2 draws half their library, and loses half their life, rounded up" do
    3.times { p2.library.add(Card("Forest")) }
    p2.lose_life(1)
    p1.add_mana(black: 7)
    p1.cast(card: peer_into_the_abyss) do
      _1.targeting(p2)
      _1.pay_mana(black: 3, generic: { black: 4 })
    end
    game.tick!

    expect(p2.library.count).to eq(1)
    expect(p2.life).to eq(9)
  end
end
