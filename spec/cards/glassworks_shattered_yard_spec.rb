# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlassworksShatteredYard do
  include_context "two player game"

  context "Glassworks" do
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:ogre) { ResolvePermanent("Shroudstomper", owner: p2) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { go_to_main_phase! }

    it "deals 4 damage to target creature an opponent controls when unlocked" do
      room = ResolvePermanent("Glassworks Shattered Yard", doors: [:right])
      p1.add_mana(red: 3)
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.settle!

      choice = game.choices.first
      expect(choice.choices).to contain_exactly(ogre, bears)
      game.resolve_choice!(target: bears)
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
      expect(mine.zone).to be_battlefield
      expect(ogre.zone).to be_battlefield
    end
  end

  context "Glassworks cast with a single opposing creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "targets it automatically" do
      go_to_main_phase!
      card = Card("Glassworks Shattered Yard", owner: p1)
      p1.hand.add(card)
      p1.add_mana(red: 3)
      p1.cast(card: card, door: :left) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
    end
  end

  context "Shattered Yard" do
    it "deals 1 damage to each opponent at the beginning of its controller's end step" do
      go_to_main_phase!
      ResolvePermanent("Glassworks Shattered Yard", doors: [:right])
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(20)
    end

    it "does nothing at the opponent's end step" do
      ResolvePermanent("Glassworks Shattered Yard", doors: [:right])
      game.next_turn
      go_to_main_phase!
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "does nothing while the door is locked" do
      go_to_main_phase!
      ResolvePermanent("Glassworks Shattered Yard", doors: [:left])
      game.settle!
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(20)
    end
  end
end
