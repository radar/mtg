require 'spec_helper'

RSpec.describe Magic::Cards::DaybreakCharger do
  include_context "two player game"


  context "ETB Event" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "buffs a target" do
      cast_and_resolve(card: Card("Daybreak Charger"), player: p1)
      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::DaybreakCharger::Choice)
      game.resolve_choice!(target: wood_elves)
      game.tick!
      expect(wood_elves.power).to eq(3)
    end
  end
end
