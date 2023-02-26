require 'spec_helper'

RSpec.describe Magic::Cards::DaybreakCharger do
  include_context "two player game"


  context "ETB Event" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "buffs a target" do
      cast_and_resolve(card: Card("Daybreak Charger"), player: p1)
      apply_buff_effect = game.next_effect
      expect(apply_buff_effect).to be_a(Magic::Effects::ApplyBuff)
      game.resolve_pending_effect(wood_elves)
      expect(wood_elves.power).to eq(3)
    end
  end
end
