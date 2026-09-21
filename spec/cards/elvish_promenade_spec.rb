# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvishPromenade do
  include_context "two player game"
  before { go_to_main_phase! }

  subject { Card("Elvish Promenade") }

  context "with no elves" do
    it "creates no Elf Warrior tokens when cast" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      expect(p1.permanents.by_name("Elf Warrior").count).to eq(0)
    end
  end

  context "with one elf" do
    before do
      ResolvePermanent("Llanowar Elves", owner: p1)
    end

    it "creates a 1/1 green Elf Warrior token for each Elf you control" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      tokens = p1.permanents.by_name("Elf Warrior")
      expect(tokens.count).to eq(1)
      expect(tokens.first.power).to eq(1)
      expect(tokens.first.toughness).to eq(1)
      expect(tokens.first.colors).to eq([:green])
    end
  end

  context "with three elves" do
    before do
      3.times { ResolvePermanent("Llanowar Elves", owner: p1) }
    end

    it "creates a token for each Elf you control" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      expect(p1.permanents.by_name("Elf Warrior").count).to eq(3)
    end
  end

  context "with an opponent's elves" do
    before do
      ResolvePermanent("Llanowar Elves", owner: p2)
    end

    it "does not count the opponent's Elves" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      expect(p1.permanents.by_name("Elf Warrior").count).to eq(0)
    end
  end
end
