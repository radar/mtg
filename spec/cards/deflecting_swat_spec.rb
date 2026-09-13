# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeflectingSwat do
  include_context "two player game"

  let(:deflecting_swat) { Card("Deflecting Swat", owner: p1) }
  let(:lightning_bolt) { Card("Lightning Bolt", owner: p2) }

  let!(:bolt_action) do
    p2.add_mana(red: 1)
    action = cast_action(card: lightning_bolt, player: p2)
    action.pay_mana(red: 1)
    action.targeting(p1)
    game.take_action(action)
    action
  end

  context "when cast targeting a spell with a legal new target" do
    before do
      p1.add_mana(red: 3)
      action = cast_action(card: deflecting_swat, player: p1)
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.targeting(bolt_action)
      game.take_action(action)
      game.stack.resolve!
    end

    it "offers to choose new targets" do
      expect(game.choices.first).to be_a(described_class::MayRetargetChoice)
    end

    it "redirects the spell to the newly chosen target when accepted" do
      game.resolve_choice!
      game.resolve_choice!(target: p2)
      game.stack.resolve!

      expect(p2.life).to eq(17)
      expect(p1.life).to eq(20)
    end

    it "leaves the original target when declined" do
      game.skip_choice!
      game.stack.resolve!

      expect(p1.life).to eq(17)
      expect(p2.life).to eq(20)
    end
  end

  context "when you control a commander" do
    before { p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1)) }

    it "may be cast without paying its mana cost" do
      p1.hand.add(deflecting_swat)
      action = cast_action(card: deflecting_swat, player: p1)
      action.mana_cost = {}
      action.targeting(bolt_action)
      expect(action.can_perform?).to be true

      game.take_action(action)
      game.stack.resolve!
      game.resolve_choice!
      game.resolve_choice!(target: p2)
      game.stack.resolve!

      expect(p2.life).to eq(17)
    end
  end
end
