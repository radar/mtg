# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Necromentia do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:in_hand) { Card("Grizzly Bears", owner: p2) }
  let(:in_graveyard) { Card("Grizzly Bears", owner: p2) }
  let(:in_library) { Card("Grizzly Bears", owner: p2) }
  let(:other) { Card("Wood Elves", owner: p2) }

  before do
    p2.hand.add(in_hand)
    p2.hand.add(other)
    p2.graveyard.add(in_graveyard)
    p2.library.add(in_library)
  end

  def cast(name)
    card = Card("Necromentia", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 2).targeting(p2) }
    game.stack.resolve!
    game.settle!
    game.resolve_choice!(name:)
    game.settle!
  end

  def zombies = p2.creatures.by_name("Zombie")

  it "exiles every card with the chosen name from the opponent's hand, graveyard and library" do
    cast("Grizzly Bears")

    expect([in_hand, in_graveyard, in_library].map(&:zone)).to all(be_exile)
    expect(other.zone).to be_hand
  end

  it "gives the opponent a 2/2 black Zombie for each card exiled from their hand" do
    p2.hand.add(Card("Grizzly Bears", owner: p2))
    cast("Grizzly Bears")

    expect(zombies.count).to eq(2)
    expect([zombies.first.power, zombies.first.toughness]).to eq([2, 2])
    expect(zombies.first.colors).to eq([:black])
  end

  it "makes no Zombies when nothing was in their hand" do
    p2.hand.remove(in_hand)
    cast("Grizzly Bears")

    expect(zombies.count).to eq(0)
  end

  it "rejects a basic land name" do
    card = Card("Necromentia", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 2).targeting(p2) }
    game.stack.resolve!
    game.settle!

    expect { game.resolve_choice!(name: "Forest") }.to raise_error(ArgumentError, /basic land/)
  end
end
