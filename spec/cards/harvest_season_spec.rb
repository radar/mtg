# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HarvestSeason do
  include_context "two player game"

  it "searches the library for up to X basic lands, where X is the number of tapped creatures you control, and puts them onto the battlefield tapped" do
    creature1 = ResolvePermanent("Grizzly Bears", owner: p1)
    creature2 = ResolvePermanent("Grizzly Bears", owner: p1)
    creature1.tap!
    creature2.tap!

    spell = Card("Harvest Season", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
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

  it "searches for zero lands when no creatures are tapped" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    spell = Card("Harvest Season", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice.upto).to eq(0)

    game.resolve_choice!(targets: [])
  end

  it "does not count tapped creatures controlled by an opponent" do
    ResolvePermanent("Grizzly Bears", owner: p1).tap!
    ResolvePermanent("Grizzly Bears", owner: p2).tap!

    spell = Card("Harvest Season", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice.upto).to eq(1)

    game.resolve_choice!(targets: [])
  end
end
