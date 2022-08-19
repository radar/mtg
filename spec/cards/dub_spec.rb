require 'spec_helper'

RSpec.describe Magic::Cards::Dub do
  include_context "two player game"

  subject { Card("Dub", controller: p1) }

  context "resolution" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

    it "buffs wood elves, gives them first strike and makes them a knight" do
      p1.add_mana(white: 3)
      action = cast_action(player: p1, card: subject)
        .pay_mana(white: 1, generic: { white: 2 })
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      expect(wood_elves.power).to eq(3)
      expect(wood_elves.toughness).to eq(3)
      expect(wood_elves.first_strike?).to eq(true)
      expect(wood_elves.type?("Knight")).to eq(true)

      expect(p1.permanents.by_name("Dub").count).to eq(1)
    end
  end
end
