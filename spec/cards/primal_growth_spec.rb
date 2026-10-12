# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrimalGrowth do
  include_context "two player game"
  before { go_to_main_phase! }

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

    it "can still be cast when the creature sacrificed sets off a trigger that is now on the stack" do
      ResolvePermanent("Poison-Tip Archer", owner: p1)
      creature = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Primal Growth", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 3)

      expect do
        p1.cast(card: spell) do |a|
          a.pay_mana(generic: { green: 2 }, green: 1)
          a.pay_kicker(creature)
          game.check_state_based_actions!
          expect(game.stack.count).to eq(1), "the trigger is on the stack while the spell is being cast"
        end
      end.not_to raise_error

      game.settle!
      game.resolve_choice!(targets: [])
      game.settle!
      expect(p2.life).to eq(p2.starting_life - 1)
    end
  end
end
