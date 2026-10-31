# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GenerousEnt do
  include_context "two player game"

  it "is a 5/7 Treefolk with reach" do
    ent = ResolvePermanent("Generous Ent", owner: p1)

    expect([ent.power, ent.toughness]).to eq([5, 7])
    expect(ent.type?("Treefolk")).to be(true)
    expect(ent).to have_keyword(:reach)
  end

  it "creates a Food token for its controller when it enters" do
    ResolvePermanent("Generous Ent", owner: p1)
    game.settle!

    expect(p1.permanents.count { _1.type?("Food") }).to eq(1)
    expect(p2.permanents.count { _1.type?("Food") }).to eq(0)
  end

  it "has forestcycling {1}" do
    card = Card("Generous Ent", owner: p1)
    p1.hand.add(card)
    forest = Card("Forest", owner: p1)
    island = Card("Island", owner: p1)
    p1.library.add(island)
    p1.library.add(forest)
    p1.add_mana(green: 1)
    p1.cycle(card:) { _1.pay_mana(generic: { green: 1 }) }

    choice = game.choices.last
    expect(choice.choices).to include(forest)
    expect(choice.choices).not_to include(island)
    choice.resolve!(targets: [forest])

    expect(card.zone).to be_graveyard
    expect(forest.zone).to be_hand
    expect(island.zone).to be_library
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "can't be cycled without paying {1}" do
    card = Card("Generous Ent", owner: p1)
    p1.hand.add(card)

    expect { p1.cycle(card:) { |_| } }.to raise_error(StandardError)
    expect(card.zone).to be_hand
  end
end
