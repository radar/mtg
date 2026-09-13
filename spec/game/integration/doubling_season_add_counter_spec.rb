require "spec_helper"

RSpec.describe Magic::Game, "Doubling Season + Permanent#add_counter" do
  include_context "two player game"

  let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }

  it "doubles counters added by cards that call Permanent#add_counter directly, not just trigger_effect(:add_counter)" do
    champion = ResolvePermanent("Setessan Champion", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(champion.counters.count).to eq(2)
  end

  it "also doubles counters from an instant's resolve! (Feat of Resistance), not just a triggered ability" do
    wood_elves = ResolvePermanent("Wood Elves", owner: p1)
    card = Card("Feat Of Resistance")
    p1.hand.add(card)
    p1.add_mana(white: 2)

    p1.cast(card: card) do |a|
      a.pay_mana(generic: { white: 1 }, white: 1)
      a.targeting(wood_elves)
    end
    game.stack.resolve!
    game.resolve_choice!(color: "blue")

    expect(wood_elves.counters.count).to eq(2)
  end
end
