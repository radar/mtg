# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThranduilSindarinLiege do
  include_context "two player game"

  let(:card) { Card("Thranduil, Sindarin Liege", owner: p1) }

  it "gives other Elves you control +1/+1 but not itself or non-Elves" do
    thranduil = ResolvePermanent("Thranduil, Sindarin Liege", owner: p1)
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect([thranduil.power, thranduil.toughness]).to eq([2, 3])
    expect([elf.power, elf.toughness]).to eq([2, 2])
    expect(bears.power).to eq(2)
  end

  it "creates a 1/1 green Elf token on landfall" do
    ResolvePermanent("Thranduil, Sindarin Liege", owner: p1)
    go_to_main_phase!
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.settle!

    tokens = p1.creatures.select { _1.token? && _1.type?("Elf") }
    expect(tokens.count).to eq(1)
    expect(tokens.first.colors).to eq([:green])
  end

  context "Silvan Rally" do
    before do
      go_to_main_phase!
      p1.hand.add(card)
    end

    def cast_rally
      p1.add_mana(green: 3)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { green: 1 }, green: 2) }
      game.stack.resolve!
    end

    it "mills four and puts up to two lands from among them into your hand" do
      forests = Array.new(4) { Card("Forest", owner: p1) }
      forests.each { p1.library.add(_1) }
      cast_rally

      expect(p1.graveyard.cards).to include(*forests)
      game.resolve_choice!(targets: forests.first(2))

      expect(p1.hand.cards).to include(*forests.first(2))
      expect(p1.graveyard.cards).to include(*forests.last(2))
      expect(card.zone).to be_exile
    end

    it "offers no choice when no lands were milled" do
      4.times { p1.library.add(Card("Grizzly Bears", owner: p1)) }
      cast_rally

      expect(game.choices).to be_empty
      expect(card.on_adventure).to eq(true)
    end
  end
end
