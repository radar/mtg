# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RevengeOfTheRats do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Revenge Of The Rats", owner: p1) }

  def rats(player = p1) = player.creatures.select { _1.name == "Rat" }

  def cast(flashback: false)
    p1.hand.add(card) unless flashback
    p1.add_mana(black: 4)
    p1.cast(card:, flashback:) { |a| a.pay_mana(generic: { black: 2 }, black: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "creates a tapped 1/1 black Rat for each creature card in your graveyard" do
    2.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
    p1.graveyard.add(Card("Island", owner: p1))
    cast

    expect(rats.size).to eq(2)
    expect(rats).to all(be_tapped)
    expect(rats.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
    expect(rats.first.colors).to eq([:black])
  end

  it "creates nothing with no creature cards in your graveyard" do
    p1.graveyard.add(Card("Island", owner: p1))
    cast

    expect(rats).to be_empty
  end

  it "ignores the opponent's graveyard" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    cast

    expect(rats).to be_empty
    expect(rats(p2)).to be_empty
  end

  it "can be cast again with flashback, counting the creature cards then" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    cast
    expect(rats.size).to eq(1)

    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    cast(flashback: true)

    expect(rats.size).to eq(1 + 2)
    expect(card.zone).to be_a(Magic::Zones::Exile).or be_nil
  end
end
