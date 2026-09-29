# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SaplingNursery do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:nursery) { ResolvePermanent("Sapling Nursery", owner: p1) }

  it "has affinity for Forests: costs {1} less for each Forest you control" do
    3.times { ResolvePermanent("Forest", owner: p1) }
    card = Card("Sapling Nursery", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 5)

    p1.cast(card:) { _1.pay_mana(generic: { green: 3 }, green: 2) }
    game.stack.resolve!

    expect(p1.permanents.map(&:name)).to include("Sapling Nursery")
  end

  it "does not count an opponent's Forests" do
    ResolvePermanent("Forest", owner: p2)
    card = Card("Sapling Nursery", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 7)

    expect { p1.cast(card:) { _1.pay_mana(generic: { green: 5 }, green: 2) } }.to raise_error(StandardError)
  end

  it "creates a 3/4 green Treefolk with reach when a land enters under your control" do
    nursery
    ResolvePermanent("Forest", owner: p1)
    treefolk = p1.creatures.find { _1.name == "Treefolk" }

    expect(treefolk).not_to be_nil
    expect([treefolk.power, treefolk.toughness, treefolk.colors]).to eq([3, 4, [:green]])
    expect(treefolk).to be_reach
  end

  it "does not trigger on an opponent's land" do
    nursery
    ResolvePermanent("Forest", owner: p2)

    expect(p1.creatures).to be_empty
  end

  it "can be exiled for {1}{G} to give Treefolk and Forests you control indestructible" do
    nursery
    ResolvePermanent("Forest", owner: p1)
    treefolk = p1.creatures.find { _1.name == "Treefolk" }
    forest = p1.permanents.find { _1.name == "Forest" }
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 2)
    p1.activate_ability(ability: nursery.activated_abilities.first) { _1.pay_mana(generic: { green: 1 }, green: 1).pay_self_exile }
    game.stack.resolve!
    game.tick!

    expect(nursery.card.zone).to be_exile
    expect(treefolk).to be_indestructible
    expect(forest).to be_indestructible
    expect(other).not_to be_indestructible
  end
end
