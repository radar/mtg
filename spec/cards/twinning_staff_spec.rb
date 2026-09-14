# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwinningStaff do
  include_context "two player game"

  let!(:twinning_staff) { ResolvePermanent("Twinning Staff", owner: p1) }

  describe "activated ability" do
    it "copies target instant or sorcery spell you control, offering new targets for the copy" do
      p1.add_mana(red: 1)
      shock_action = cast_action(player: p1, card: Card("Shock", owner: p1))
        .pay_mana(red: 1)
        .targeting(p2)
      shock_action.perform

      p1.add_mana(red: 7)
      p1.activate_ability(ability: twinning_staff.activated_abilities.first) do |ability|
        ability.targeting(shock_action)
        ability.pay_mana(generic: { red: 7 })
      end
      game.stack.resolve!

      # Twinning Staff's own static ability adds an additional copy on top of
      # its activated ability's single copy.
      game.skip_choice!

      game.stack.resolve!

      expect(p2.life).to eq(20 - 2 - 2 - 2)
    end
  end

  describe "static ability" do
    it "adds an additional copy whenever a spell would be copied" do
      p1.add_mana(red: 1)
      shock_action = cast_action(player: p1, card: Card("Shock", owner: p1))
        .pay_mana(red: 1)
        .targeting(p2)
      shock_action.perform

      reiterate = Card("Reiterate", owner: p1)
      p1.hand.add(reiterate)
      p1.add_mana(red: 3)
      cast_action(player: p1, card: reiterate)
        .pay_mana(generic: { red: 1 }, red: 2)
        .targeting(shock_action)
        .perform

      game.stack.resolve!
      game.skip_choice!

      game.stack.resolve!

      expect(p2.life).to eq(20 - 2 - 2 - 2)
    end
  end
end
