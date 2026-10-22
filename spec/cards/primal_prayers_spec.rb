# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrimalPrayers do
  include_context "two player game"

  let!(:prayers) { ResolvePermanent("Primal Prayers", owner: p1) }

  def in_hand(name, owner: p1) = Card(name, owner: owner).tap { owner.hand.add(_1) }

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  context "at sorcery speed" do
    before { go_to_main_phase! }

    it "lets you cast a creature with mana value 3 or less by paying {E} instead of its mana cost" do
      bears = in_hand("Grizzly Bears") # {1}{G}
      p1.cast(card: bears, pay_static_alternative: true)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.energy).to eq(1)
    end

    it "works for a mana value 3 creature" do
      expect(in_hand("Wood Elves").mana_value).to eq(3)
      p1.cast(card: in_hand("Wood Elves"), pay_static_alternative: true)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Wood Elves")
    end

    it "doesn't apply to a creature with mana value 4 or more" do
      angel = in_hand("Baneslayer Angel")

      expect { p1.cast(card: angel, pay_static_alternative: true) }.to raise_error(StandardError)
      expect(p1.energy).to eq(2)
    end

    it "doesn't apply to noncreature spells" do
      expect { p1.cast(card: in_hand("Lightning Bolt"), pay_static_alternative: true) { _1.targeting(p2) } }
        .to raise_error(StandardError)
      expect(p1.energy).to eq(2)
    end

    it "can't be used without energy" do
      p1.pay_energy!(2)

      expect { p1.cast(card: in_hand("Grizzly Bears"), pay_static_alternative: true) }.to raise_error(StandardError)
    end

    it "is optional: you can still pay the mana cost" do
      p1.add_mana(green: 2)
      p1.cast(card: in_hand("Grizzly Bears")) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.energy).to eq(2)
    end

    it "doesn't let your opponent use it" do
      game.next_turn
      go_to_main_phase!
      prayers.trigger_effect(:add_counter, counter_type: "energy", target: p2, amount: 1)
      game.settle!
      expect(p2.energy).to eq(1)
      cub = in_hand("Grizzly Bears", owner: p2)

      expect { p2.cast(card: cub, pay_static_alternative: true) }.to raise_error(StandardError)
    end
  end

  context "flash" do
    it "lets you cast a creature spell this way at instant speed" do
      bears = in_hand("Grizzly Bears")
      p1.cast(card: bears, pay_static_alternative: true)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "doesn't give flash when you pay the mana cost" do
      p1.add_mana(green: 2)

      expect { p1.cast(card: in_hand("Grizzly Bears")) { _1.pay_mana(generic: { green: 1 }, green: 1) } }
        .to raise_error(StandardError, /sorcery speed/)
    end
  end
end
