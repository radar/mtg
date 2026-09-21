# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VastwoodSurge do
  include_context "two player game"
  before { go_to_main_phase! }

  it "searches the library for up to two basic lands and puts them onto the battlefield tapped" do
    spell = Card("Vastwood Surge", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 4)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(described_class::Choice)
    expect(choice.upto).to eq(2)
    expect(choice.choices).to all(be_basic_land)

    forests = choice.choices.first(2)
    game.resolve_choice!(targets: forests)

    forests.each do |forest|
      expect(forest.zone).to be_battlefield
      expect(game.battlefield.by_card(forest).first).to be_tapped
    end
  end

  context "when not kicked" do
    it "does not add counters to creatures" do
      creature = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Vastwood Surge", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 4)

      p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
      game.stack.resolve!

      game.resolve_choice!(targets: [])

      expect(creature.counters.count).to eq(0)
    end
  end

  context "when kicked" do
    it "puts two +1/+1 counters on each creature you control" do
      creature = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Vastwood Surge", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 8)

      p1.cast(card: spell) do |a|
        a.pay_mana(generic: { green: 3 }, green: 1)
        a.pay_kicker(generic: { green: 4 })
      end
      game.stack.resolve!

      game.resolve_choice!(targets: [])

      expect(creature.counters.count).to eq(2)
    end
  end
end
