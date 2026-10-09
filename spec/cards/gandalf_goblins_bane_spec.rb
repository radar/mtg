# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GandalfGoblinsBane do
  include_context "two player game"

  def p1_library
    [
      *7.times.map { Card("Forest") },
      # End initial card draw
      Card("Island"),
      Card("Grizzly Bears"),
      Card("Swamp"),
      Card("Mountain"),
    ]
  end

  before { go_to_main_phase! }

  context "as a creature" do
    let!(:gandalf) { ResolvePermanent("Gandalf, Goblins' Bane", owner: p1) }

    it "is a 2/3 legendary Avatar Wizard" do
      expect([gandalf.power, gandalf.toughness]).to eq([2, 3])
      expect(gandalf.type?("Wizard")).to eq(true)
    end

    it "gets +1/+1 and pings each opponent when you cast a noncreature spell" do
      spell = Card("Shock", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(red: 1)
      expect do
        p1.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(p2) }
        game.settle!
      end.to change { p2.life }.by(-3) # 2 from Shock, 1 from Gandalf
      game.tick!
      expect([gandalf.power, gandalf.toughness]).to eq([3, 4])
    end

    it "doesn't trigger for a creature spell" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.add_mana(green: 2)
      expect do
        p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
        game.settle!
      end.not_to(change { p2.life })
    end
  end

  context "as Flameshape" do
    let(:card) { Card("Gandalf, Goblins' Bane", owner: p1) }

    before do
      p1.hand.add(card)
      p1.add_mana(red: 2)
      p1.cast(card:, adventure: true) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
      game.stack.resolve!
      game.settle!
    end

    let(:exiled) { game.exile.cards.select { |c| c.owner == p1 && c != card } }

    it "exiles the top two cards of your library and puts Gandalf on an adventure" do
      # The draw step took the Island, so Bears and Swamp are on top.
      expect(exiled.map(&:name)).to contain_exactly("Grizzly Bears", "Swamp")
      expect(p1.library.count).to eq(1)
      expect(card.zone).to be_exile
    end

    it "lets you play them only while you control a Wizard" do
      bears = exiled.find { _1.name == "Grizzly Bears" }
      p1.add_mana(green: 2)
      expect(game.play_permissions.permits?(bears, p1)).to eq(false)
      ResolvePermanent("Gandalf, Goblins' Bane", owner: p1)
      expect(game.play_permissions.permits?(bears, p1)).to eq(true)
      expect(game.play_permissions.permits?(bears, p2)).to eq(false)
    end
  end
end
