# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenAmbush do
  include_context "two player game"

  context "with 1 elf" do
    before do
      ResolvePermanent("Llanowar Elves", owner: p1)
    end

    subject { Card("Elven Ambush") }

    it "creates a 1/1 Elf token when cast" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      expect(p1.permanents.by_name("Elf Warrior").count).to eq(1)
    end
  end

  context "with two elves" do
    before do
      ResolvePermanent("Llanowar Elves", owner: p1)
      ResolvePermanent("Llanowar Elves", owner: p1)
    end

    subject { Card("Elven Ambush") }

    it "creates a 1/1 Elf token when cast" do
      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.pay_mana(generic: { green: 3 }, green: 1)
      end
      game.stack.resolve!

      expect(p1.permanents.by_name("Elf Warrior").count).to eq(2)
    end
  end
end
