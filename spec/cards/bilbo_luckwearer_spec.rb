# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilboLuckwearer do
  include_context "two player game"

  let(:card) { Card("Bilbo, Luckwearer", owner: p1) }

  before { p1.hand.add(card) }

  describe "the creature" do
    let!(:bilbo) { ResolvePermanent("Bilbo, Luckwearer", owner: p1) }

    it "is a 1/1 legendary Halfling Rogue" do
      expect([bilbo.power, bilbo.toughness]).to eq([1, 1])
      expect(bilbo.card.types).to include("Halfling", "Rogue")
    end

    it "can't be blocked" do
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: bilbo, target: p2)
      current_turn.attackers_declared!

      expect { current_turn.declare_blocker(blocker, attacker: bilbo) }.to raise_error(StandardError)
    end

    it "loots when it deals combat damage to a player" do
      hand = p1.hand.count
      game.notify!(Magic::Events::DamageDealt.new(source: bilbo, target: p2, damage: 1, combat: true))
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      discard = p1.hand.first
      game.resolve_choice!(card: discard)

      expect(p1.hand.count).to eq(hand)
      expect(discard.zone).to be_graveyard
    end

    it "doesn't loot for noncombat damage" do
      game.notify!(Magic::Events::DamageDealt.new(source: bilbo, target: p2, damage: 1, combat: false))
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  describe "Burglar's Plot" do
    before { go_to_main_phase! }

    def cast_plot(*targets)
      p1.add_mana(blue: 5)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { blue: 4 }, blue: 1).targeting(*targets) }
      game.stack.resolve!
      game.settle!
    end

    it "exchanges control of two nonland permanents that share a card type, then exiles on an adventure" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Baneslayer Angel", owner: p2)
      cast_plot(mine, theirs)

      expect(mine.controller).to eq(p2)
      expect(theirs.controller).to eq(p1)
      expect(card.zone).to be_exile
      expect(card.on_adventure).to eq(true)
    end

    it "does nothing if they don't share a card type" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      ring = ResolvePermanent("Sol Ring", owner: p2)
      cast_plot(mine, ring)

      expect(mine.controller).to eq(p1)
      expect(ring.controller).to eq(p2)
    end
  end
end
