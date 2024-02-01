require 'spec_helper'

RSpec.describe Magic::Cards::FrostBreath do
  include_context "two player game"

  subject { Card("Frost Breath") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p2) }

  context "resolution" do
    it "taps two target creatures" do
      p1.add_mana(blue: 3)
      action = cast_action(card: subject, player: p1).targeting(wood_elves, loxodon_wayfarer)
      action.pay_mana(blue: 1, generic: { blue: 2 })
      game.take_action(action)
      game.tick!

      expect(wood_elves).to be_tapped
      expect(loxodon_wayfarer).to be_tapped

      game.current_turn.end!
      game.next_turn
      game.current_turn.untap!
      expect(wood_elves).to be_tapped
      expect(loxodon_wayfarer).to be_tapped

      game.current_turn.end!
      game.next_turn

      game.current_turn.end!
      game.next_turn
      game.current_turn.untap!
      expect(wood_elves).to be_untapped
      expect(loxodon_wayfarer).to be_untapped
    end
  end
end
