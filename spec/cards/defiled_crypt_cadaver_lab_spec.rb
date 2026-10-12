# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DefiledCryptCadaverLab do
  include_context "two player game"

  def horrors = p1.creatures.select { _1.type?("Horror") }

  def bury(name)
    permanent = ResolvePermanent(name, owner: p1)
    card = permanent.card
    permanent.destroy!
    game.settle!
    card
  end

  context "Defiled Crypt" do
    let!(:room) { ResolvePermanent("Defiled Crypt Cadaver Lab", doors: [:left]) }

    it "creates a 2/2 black Horror enchantment creature token when a card leaves your graveyard" do
      card = bury("Grizzly Bears")
      card.move_to_hand!
      game.settle!

      expect(horrors.size).to eq(1)
      expect([horrors.first.power, horrors.first.toughness]).to eq([2, 2])
      expect(horrors.first.colors).to eq([:black])
      expect(horrors.first.types).to include(Magic::Types::Enchantment)
    end

    it "triggers only once each turn" do
      first = bury("Grizzly Bears")
      second = bury("Grizzly Bears")
      first.move_to_hand!
      game.settle!
      second.move_to_hand!
      game.settle!

      expect(horrors.size).to eq(1)
    end

    it "does not trigger for a card leaving the opponent's graveyard" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.destroy!
      game.settle!
      p2.graveyard.cards.first.move_to_hand!
      game.settle!

      expect(horrors).to be_empty
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)
      bury("Grizzly Bears").move_to_hand!
      game.settle!

      expect(horrors).to be_empty
    end
  end

  context "Cadaver Lab" do
    before { go_to_main_phase! }

    it "returns target creature card from your graveyard to your hand when unlocked" do
      room = ResolvePermanent("Defiled Crypt Cadaver Lab", doors: [:left])
      card = bury("Grizzly Bears")
      other = bury("Shroudstomper")
      p1.add_mana(black: 1)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(black: 1) }
      game.settle!

      expect(game.choices.first.choices).to contain_exactly(card, other)
      game.resolve_choice!(target: card)
      game.settle!

      expect(p1.hand.cards).to include(card)
      expect(p1.graveyard.cards).to include(other)
      # Defiled Crypt is unlocked too: a card left the graveyard.
      expect(horrors.size).to eq(1)
    end

    it "does nothing with no creature card in the graveyard" do
      room = ResolvePermanent("Defiled Crypt Cadaver Lab", doors: [:left])
      p1.add_mana(black: 1)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(black: 1) }
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
