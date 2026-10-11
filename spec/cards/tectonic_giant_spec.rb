# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TectonicGiant do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:giant) { ResolvePermanent("Tectonic Giant", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(giant, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  describe "when it attacks" do
    it "can deal 3 damage to each opponent" do
      attack!
      game.resolve_choice!(mode: Magic::Cards::TectonicGiant::ModeChoice::DAMAGE)

      expect(p2.life).to eq(17)
    end

    it "can exile the top two cards and let you play one of them" do
      top = p1.library.cards.first(2)
      attack!
      game.resolve_choice!(mode: Magic::Cards::TectonicGiant::ModeChoice::EXILE)
      game.resolve_choice!(target: top.first)

      expect(top.map(&:zone)).to all(be_exile)
      expect(game.play_permissions.permits?(top.first, p1)).to be(true)
      expect(game.play_permissions.permits?(top.last, p1)).to be(false)
    end
  end

  describe "when an opponent's spell targets it" do
    before { go_to_main_phase_for!(p2) }

    it "triggers" do
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      p2.add_mana(red: 1)
      p2.cast(card: bolt) { _1.pay_mana(red: 1).targeting(giant) }
      game.settle!
      game.resolve_choice!(mode: Magic::Cards::TectonicGiant::ModeChoice::DAMAGE)

      expect(p2.life).to eq(17)
    end

    it "ignores a spell that targets something else" do
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      p2.add_mana(red: 1)
      p2.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p1) }
      game.settle!

      expect(game.choices.to_a.grep(described_class::ModeChoice)).to be_empty
    end
  end
end
