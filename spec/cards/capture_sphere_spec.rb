require 'spec_helper'

RSpec.describe Magic::Cards::CaptureSphere do
  include_context "two player game"

  subject { Card("Capture Sphere") }

  context "resolution" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    # Capture Sphere {3}{U}
    # Enchantment — Aura
    # Flash (You may cast this spell any time you could cast an instant.)
    # Enchant creature
    # When Capture Sphere enters the battlefield, tap enchanted creature.
    # Enchanted creature doesn't untap during its controller's untap step.

    it "taps enchanted creature, equips aura" do
      game.next_turn

      expect(game.current_turn.active_player).to eq(p1)
      p1.add_mana(white: 4)
      action = cast_action(player: p1, card: subject)
        .pay_mana(white: 1, generic: { white: 3 })
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      expect(wood_elves.attachments.count).to eq(1)
      expect(wood_elves.attachments.first).to be_a(Magic::Permanent)
      expect(wood_elves.attachments.first.name).to eq("Capture Sphere")
      expect(wood_elves.can_untap_during_upkeep?).to eq(false)

      expect(p1.permanents.by_name("Capture Sphere").count).to eq(1)

      game.current_turn.end!

      game.next_turn
      expect(game.current_turn.active_player).to eq(p2)

      game.current_turn.untap!
      expect(wood_elves).to be_tapped
    end
  end
end
