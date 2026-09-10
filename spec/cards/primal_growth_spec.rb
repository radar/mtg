# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrimalGrowth do
  include_context "two player game"

  it "searches the library for a basic land and puts it onto the battlefield" do
    spell = Card("Primal Growth", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(described_class::Choice)
    expect(choice.upto).to eq(1)
    expect(choice.choices).to all(be_basic_land)

    forest = choice.choices.first
    game.resolve_choice!(targets: [forest])

    expect(forest.zone).to be_battlefield
  end

  context "when kicked by sacrificing a creature" do
    it "searches for up to two basic lands instead" do
      creature = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Primal Growth", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 3)

      p1.cast(card: spell) do |a|
        a.pay_mana(generic: { green: 2 }, green: 1)
        a.pay_kicker(creature)
      end
      game.stack.resolve!

      expect(creature.zone).to be_nil
      expect(p1.graveyard.by_card(creature.card)).not_to be_empty

      choice = game.choices.last
      expect(choice.upto).to eq(2)
    end
  end
end
