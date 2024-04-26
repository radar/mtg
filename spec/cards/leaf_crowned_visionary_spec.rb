require "spec_helper"

RSpec.describe Magic::Cards::LeafCrownedVisionary do
  include_context "two player game"

  subject!(:leaf_crowned_visionary) { ResolvePermanent("Leaf-Crowned Visionary") }

  context "with another elf on the field" do
    let(:wood_elves) { ResolvePermanent("Wood Elves") }

    it "gives all other elves +1/+1" do
      expect(leaf_crowned_visionary.power).to eq(1)
      expect(leaf_crowned_visionary.toughness).to eq(1)

      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
    end
  end

  context "when an Elf spell is cast, you may pay {G}" do
    subject(:leaf_crowned_visionary) { ResolvePermanent("Leaf-Crowned Visionary") }

    let(:wood_elves) { Card("Wood Elves") }
    let(:grizzly_bears) { Card("Grizzly Bears") }

    it "doesn't trigger on the bears" do
      p1.add_mana(green: 4)
      p1.cast(card: grizzly_bears) do
        _1.pay_mana(green: 1, generic: { green: 1 })
      end

      game.stack.resolve!
      expect(game.choices).to be_empty
    end

    it "triggers on elves, and opts draw a card" do
      p1.add_mana(green: 4)
      p1.cast(card: wood_elves) do
        _1.pay_mana(green: 1, generic: { green: 2 })
      end

      game.stack.resolve!

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::LeafCrownedVisionary::Choice)
      choice.pay(player: p1, payment: {green: 1})
      choice.resolve!
    end

    it "skips choice" do
      p1.add_mana(green: 4)
      p1.cast(card: wood_elves) do
        _1.pay_mana(green: 1, generic: { green: 2 })
      end

      game.stack.resolve!

      choice = game.choices.first
      p1.skip_choice(choice)
      expect(game.choices).to be_empty
    end
  end
end
