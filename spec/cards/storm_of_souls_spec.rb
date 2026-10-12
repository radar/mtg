# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StormOfSouls do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("Storm Of Souls", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 6)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 4 }, white: 2) }
    game.stack.resolve!
    game.settle!
    card
  end

  it "returns each creature card from your graveyard as a 1/1 Spirit with flying" do
    angel = Card("Baneslayer Angel", owner: p1)
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(angel)
    p1.graveyard.add(bears)

    cast

    returned = p1.creatures.select { _1.name == "Baneslayer Angel" || _1.name == "Grizzly Bears" }
    expect(returned.count).to eq(2)
    returned.each do |creature|
      expect([creature.power, creature.toughness]).to eq([1, 1])
      expect(creature).to be_flying
      expect(creature.type?("Spirit")).to be true
    end
    expect(returned.find { _1.name == "Grizzly Bears" }.type?("Bear")).to be true
  end

  it "leaves noncreature cards and the opponent's graveyard alone" do
    land = Card("Forest", owner: p1)
    theirs = Card("Grizzly Bears", owner: p2)
    p1.graveyard.add(land)
    p2.graveyard.add(theirs)

    cast

    expect(p1.graveyard.cards).to include(land)
    expect(p2.graveyard.cards).to include(theirs)
  end

  it "exiles Storm of Souls" do
    card = cast

    expect(card.zone).to be_exile
  end
end
