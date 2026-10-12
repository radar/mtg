# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElrondMoonReader do
  include_context "two player game"

  let!(:elrond) { ResolvePermanent("Elrond, Moon-Reader", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def activate_blink(*targets)
    p1.add_mana(blue: 7)
    p1.activate_ability(ability: elrond.activated_abilities.first) do |a|
      a.targeting(*targets) if targets.any?
      a.pay_mana(generic: { blue: 5 }, blue: 2)
    end
  end

  it "is a 3/3" do
    expect([elrond.power, elrond.toughness]).to eq([3, 3])
  end

  describe "draw trigger" do
    let!(:tam) { ResolvePermanent("Tam, Mindful First-Year", owner: p1) }

    def activate_tam
      p1.activate_ability(ability: tam.activated_abilities.first) { _1.targeting(bears) }
      game.stack.resolve!
      game.settle!
    end

    it "draws a card when you activate an ability of a creature" do
      expect { activate_tam }.to change { p1.hand.count }.by(1)
    end

    it "triggers only once each turn" do
      activate_tam
      tam.untap!

      expect { activate_tam }.not_to change { p1.hand.count }
    end

    it "doesn't trigger when an opponent activates an ability of a creature" do
      go_to_main_phase_for!(p2)
      opp_tam = ResolvePermanent("Tam, Mindful First-Year", owner: p2)
      opp_bears = ResolvePermanent("Grizzly Bears", owner: p2)

      expect {
        p2.activate_ability(ability: opp_tam.activated_abilities.first) { _1.targeting(opp_bears) }
        game.stack.resolve!
        game.settle!
      }.not_to change { p1.hand.count }
    end
  end

  describe "{5}{U}{U}" do
    let!(:sword) { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    let!(:forest) { ResolvePermanent("Forest", owner: p1) }

    it "exiles up to two other target nonland permanents you control" do
      activate_blink(bears, sword)
      game.stack.resolve!
      game.settle!

      expect(game.exile.cards).to include(bears.card, sword.card)
    end

    it "can't target Elrond or a land" do
      expect { activate_blink(elrond) }.to raise_error(StandardError)
      expect { activate_blink(forest) }.to raise_error(StandardError)
    end

    it "returns them to the battlefield under their owner's control at the beginning of the next end step" do
      activate_blink(bears, sword)
      game.stack.resolve!
      game.settle!
      current_turn.end!
      game.settle!

      names = game.battlefield.controlled_by(p1).map(&:name)
      expect(names).to include("Grizzly Bears", "Well-Worn Spatula")
      expect(game.exile.cards).not_to include(bears.card)
    end
  end
end
