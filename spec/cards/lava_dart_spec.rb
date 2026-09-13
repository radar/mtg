# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LavaDart do
  include_context "two player game"

  it "deals 1 damage to any target" do
    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Lava Dart", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform
    game.stack.resolve!

    expect(p2.life).to eq(19)
  end

  describe "flashback" do
    it "can be cast from the graveyard by sacrificing a Mountain, then exiles it" do
      mountain = ResolvePermanent("Mountain", owner: p1)
      lava_dart = Card("Lava Dart", owner: p1)
      p1.graveyard.add(lava_dart)

      action = cast_action(player: p1, card: lava_dart, flashback: true)
      action.pay_mana(mountain)
      action.targeting(p2)
      action.perform
      game.stack.resolve!

      expect(p2.life).to eq(19)
      expect(mountain.zone).to be_nil
      expect(lava_dart.zone).to be_exile
    end

    it "cannot be paid without controlling a Mountain" do
      lava_dart = Card("Lava Dart", owner: p1)
      p1.graveyard.add(lava_dart)

      action = cast_action(player: p1, card: lava_dart, flashback: true)
      expect(action.can_perform?).to eq(false)
    end
  end
end
