# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JolraelMwonvuliRecluse do
  include_context "two player game"

  subject!(:jolrael) { ResolvePermanent("Jolrael, Mwonvuli Recluse", owner: p1) }

  before do
    5.times { p1.library.add(Card("Forest")) }
  end

  context "second card drawn each turn trigger" do
    before do
      # Advance back to p1's turn so events are clean.
      2.times { game.next_turn }
    end

    it "does not create a token on the first card drawn" do
      p1.draw!
      cats = creatures.by_name("Cat")
      expect(cats.count).to eq(0)
    end

    it "creates a 2/2 green Cat token on the second card drawn" do
      p1.draw!
      p1.draw!

      cats = creatures.by_name("Cat")
      expect(cats.count).to eq(1)
      cat = cats.first
      expect(cat.power).to eq(2)
      expect(cat.toughness).to eq(2)
      expect(cat.colors).to eq([:green])
      expect(cat.controller).to eq(p1)
    end

    it "does not create a token on the third or later card drawn" do
      p1.draw!
      p1.draw!
      p1.draw!

      cats = creatures.by_name("Cat")
      expect(cats.count).to eq(1)
    end

    it "does not trigger on opponent's draws" do
      p2.draw!
      p2.draw!

      cats = creatures.by_name("Cat")
      expect(cats.count).to eq(0)
    end
  end

  context "{4}{G}{G} activated ability" do
    let!(:elf) { ResolvePermanent("Llanowar Elves", owner: p1) }

    it "sets the base power and toughness of creatures you control to the number of cards in your hand" do
      x = p1.hand.count
      expect(x).to be > 0

      p1.add_mana(green: 6)
      p1.activate_ability(ability: jolrael.activated_abilities.first) do
        _1.pay_mana(green: 2, generic: { green: 4 })
      end

      game.stack.resolve!
      game.tick!

      expect(jolrael.power).to eq(x)
      expect(jolrael.toughness).to eq(x)
      expect(elf.power).to eq(x)
      expect(elf.toughness).to eq(x)
    end

    it "expires at end of turn" do
      p1.add_mana(green: 6)
      p1.activate_ability(ability: jolrael.activated_abilities.first) do
        _1.pay_mana(green: 2, generic: { green: 4 })
      end

      game.stack.resolve!
      game.tick!

      game.current_turn.end!
      game.current_turn.cleanup!
      game.tick!

      expect(jolrael.power).to eq(2)
      expect(jolrael.toughness).to eq(3)
    end
  end
end
