require "spec_helper"

RSpec.describe Magic::Game, "action legality -- casting spells" do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:bolt) { Card("Lightning Bolt", owner: p1) }
  let(:priest) { Card("Containment Priest", owner: p1) }

  before do
    p1.hand.add(bears)
    p1.hand.add(bolt)
    p1.hand.add(priest)
  end

  def cast_bears
    p1.add_mana(green: 2)
    p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
  end

  context "a sorcery-speed spell (a creature without flash)" do
    it "can be cast in the active player's main phase with an empty stack" do
      go_to_main_phase!
      cast_bears
      game.stack.resolve!

      expect(bears.zone).to be_battlefield
    end

    it "cannot be cast outside a main phase" do
      go_to_main_phase!
      current_turn.beginning_of_combat!

      expect { cast_bears }.to raise_error(Magic::IllegalAction, /not a main phase/)
    end

    it "cannot be cast during the upkeep step" do
      current_turn.untap!
      current_turn.upkeep!

      expect { cast_bears }.to raise_error(Magic::IllegalAction, /not a main phase/)
    end

    it "cannot be cast on the opponent's turn" do
      go_to_main_phase_for!(p2)

      expect { cast_bears }.to raise_error(Magic::IllegalAction, /not .*P1.*turn/)
    end

    it "cannot be cast while the stack is not empty" do
      go_to_main_phase!
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

      expect { cast_bears }.to raise_error(Magic::IllegalAction, /stack is not empty/)
    end

    it "does not put the spell on the stack when illegal" do
      go_to_main_phase!
      current_turn.beginning_of_combat!

      expect { cast_bears }.to raise_error(Magic::IllegalAction)
      expect(game.stack).to be_empty
    end
  end

  context "an instant" do
    it "can be cast in any step" do
      current_turn.untap!
      current_turn.upkeep!
      p1.add_mana(red: 1)

      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

      expect(game.stack.spells.map(&:card)).to eq([bolt])
    end

    it "can be cast on the opponent's turn" do
      go_to_main_phase_for!(p2)
      p1.add_mana(red: 1)

      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

      expect(game.stack.spells.map(&:card)).to eq([bolt])
    end

    it "can be cast while the stack is not empty" do
      go_to_main_phase!
      p1.add_mana(red: 2)
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

      other_bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(other_bolt)
      p1.cast(card: other_bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

      expect(game.stack.spells.count).to eq(2)
    end
  end

  context "a creature with flash" do
    it "can be cast outside a main phase and on the opponent's turn" do
      go_to_main_phase_for!(p2)
      p1.add_mana(white: 2)

      p1.cast(card: priest) { |a| a.pay_mana(generic: { white: 1 }, white: 1) }

      expect(game.stack.spells.map(&:card)).to eq([priest])
    end
  end

  context "zones" do
    it "cannot be cast from the library" do
      go_to_main_phase!
      card = Card("Grizzly Bears", owner: p1)
      p1.library.add(card)
      p1.add_mana(green: 2)

      expect {
        p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      }.to raise_error(Magic::IllegalAction, /not in a zone it can be cast from/)
    end

    it "cannot be cast from the graveyard without flashback" do
      go_to_main_phase!
      p1.graveyard.add(bolt)
      p1.hand.remove(bolt)
      p1.add_mana(red: 1)

      expect {
        p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
      }.to raise_error(Magic::IllegalAction, /not in a zone it can be cast from/)
    end

    it "cannot be cast from exile without a permission" do
      go_to_main_phase!
      p1.hand.remove(bolt)
      bolt.exile!
      p1.add_mana(red: 1)

      expect {
        p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
      }.to raise_error(Magic::IllegalAction, /not in a zone it can be cast from/)
    end
  end

  context "when an effect limits the player to one spell per turn" do
    it "cannot cast a second spell" do
      go_to_main_phase!
      p1.limit_spells_this_turn!(1)
      p1.add_mana(red: 2)
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      other_bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(other_bolt)

      expect {
        p1.cast(card: other_bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
      }.to raise_error(Magic::IllegalAction, /cannot cast any more spells/)
    end
  end

  context "a spell cast because an effect told the player to (by_effect)" do
    it "ignores timing" do
      go_to_main_phase!
      current_turn.beginning_of_combat!
      p1.add_mana(green: 2)

      p1.cast(card: bears, by_effect: true) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.stack.spells.map(&:card)).to eq([bears])
    end
  end
end
