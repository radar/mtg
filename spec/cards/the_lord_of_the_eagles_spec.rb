# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheLordOfTheEagles do
  include_context "two player game"

  let(:card) { Card("The Lord Of The Eagles", owner: p1) }

  before { p1.hand.add(card) }

  it "is an 8/8 flash flyer" do
    permanent = ResolvePermanent("The Lord Of The Eagles", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([8, 8])
    expect(permanent).to have_keyword(:flying)
    expect(permanent).to have_keyword(:flash)
  end

  it "costs the full {7}{U}{U} with no flyers" do
    p1.add_mana(blue: 8)

    expect { p1.cast(card:) { _1.pay_mana(generic: { blue: 7 }, blue: 2) } }.to raise_error(StandardError)
  end

  it "costs {X} less where X is the total power of your creatures with flying" do
    ResolvePermanent("Concordia Pegasus", owner: p1) # 1/3 flyer
    ResolvePermanent("Concordia Pegasus", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1) # no flying, doesn't count
    ResolvePermanent("Concordia Pegasus", owner: p2) # not yours
    game.tick!
    p1.add_mana(blue: 9)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 5 }, blue: 2) }

    expect(game.stack.spells.map(&:card)).to include(card)
    expect(p1.mana_pool[:blue]).to eq(2)
  end

  it "can be cast at instant speed" do
    p1.add_mana(blue: 9)
    expect { p1.cast(card:) { _1.pay_mana(generic: { blue: 7 }, blue: 2) } }.not_to raise_error
  end
end
