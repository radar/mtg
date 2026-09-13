require "spec_helper"

RSpec.describe Magic::Game, "Spelunking + Vastwood Surge" do
  include_context "two player game"

  it "puts the lands Vastwood Surge searches for onto the battlefield untapped" do
    ResolvePermanent("Spelunking", owner: p1)
    game.skip_choice! # decline Spelunking's own "put a land from hand" choice from its ETB draw

    spell = Card("Vastwood Surge", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 4)

    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
    game.stack.resolve!

    choice = game.choices.first
    forests = choice.choices.first(2)
    game.resolve_choice!(targets: forests)

    forests.each do |forest|
      expect(forest.zone).to be_battlefield
      expect(game.battlefield.by_card(forest).first).to be_untapped
    end
  end
end
