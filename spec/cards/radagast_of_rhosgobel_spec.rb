# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RadagastOfRhosgobel do
  include_context "two player game"

  let!(:radagast) { ResolvePermanent("Radagast Of Rhosgobel", owner: p1) }

  it "is a 2/5 Avatar Wizard" do
    expect([radagast.power, radagast.toughness]).to eq([2, 5])
  end

  context "in your main phase" do
    before { go_to_main_phase! }

    it "makes the first creature spell cost {2} less" do
      bear = Card("Ordinary Bear", owner: p1)
      p1.hand.add(bear)
      p1.add_mana(green: 2)
      p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Ordinary Bear")
    end

    it "doesn't reduce the second creature spell" do
      first = Card("Grizzly Bears", owner: p1)
      second = Card("Ordinary Bear", owner: p1)
      p1.hand.add(first)
      p1.hand.add(second)
      p1.add_mana(green: 10)
      p1.cast(card: first) { |a| a.pay_mana(green: 1) }
      game.stack.resolve!

      action = p1.cast(card: second) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
      game.stack.resolve!

      expect(action.mana_cost.cost).to include(generic: 3, green: 1)
      expect(p1.creatures.map(&:name)).to include("Ordinary Bear")
    end

    it "doesn't reduce noncreature spells" do
      bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
      action = cast_action(card: bolt, player: p1)

      expect(action.mana_cost.cost).to eq(red: 1)
    end
  end

  context "at instant speed" do
    it "lets you cast the first creature spell with flash" do
      go_to_main_phase_for!(p2)
      bear = Card("Ordinary Bear", owner: p1)
      p1.hand.add(bear)
      p1.add_mana(green: 2)
      p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Ordinary Bear")
    end

    it "doesn't give flash to the second creature spell" do
      go_to_main_phase_for!(p2)
      first = Card("Grizzly Bears", owner: p1)
      second = Card("Grizzly Bears", owner: p1)
      p1.hand.add(first)
      p1.hand.add(second)
      p1.add_mana(green: 10)
      p1.cast(card: first) { |a| a.pay_mana(green: 1) }
      game.stack.resolve!

      expect { p1.cast(card: second) { |a| a.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(Magic::IllegalAction)
    end

    it "gives an opponent no benefit" do
      go_to_main_phase_for!(p2)
      bear = Card("Grizzly Bears", owner: p2)
      p2.hand.add(bear)
      p2.add_mana(green: 2)
      action = cast_action(card: bear, player: p2)

      expect(action.mana_cost.cost).to include(generic: 1)
    end
  end
end
