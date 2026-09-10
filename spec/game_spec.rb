require "spec_helper"

RSpec.describe Magic::Game do
  include_context "two player game"

  context "take additional turn" do
    it "player 1 has turns 1 and 2" do
      game.take_additional_turn
      expect(game.turns.size).to eq(2)
      expect(game.turns.map(&:number)).to eq([1, 2])

      expect(game.current_turn.number).to eq(1)
      expect(game.current_turn.active_player).to eq(p1)

      game.next_turn

      expect(game.current_turn.number).to eq(2)
      expect(game.current_turn.active_player).to eq(p1)
    end
  end

  context "next_turn" do
    it "player 1 has turns 1 and 2" do
      expect(game.current_turn.number).to eq(1)
      expect(game.current_turn.active_player).to eq(p1)

      game.next_turn

      expect(game.current_turn.number).to eq(2)
      expect(game.current_turn.active_player).to eq(p2)
    end
  end

  context "monarch" do
    it "make_monarch! sets the monarch" do
      game.make_monarch!(p1)

      expect(game.monarch).to eq(p1)
      expect(p1.monarch?).to be true
      expect(p2.monarch?).to be false
    end

    it "the monarch draws a card at the beginning of their end step" do
      game.make_monarch!(p1)

      expect { game.current_turn.end! }.to change { p1.hand.count }.by(1)
    end

    it "does not draw a card for a non-monarch player's end step" do
      game.make_monarch!(p2)

      expect { game.current_turn.end! }.not_to(change { p2.hand.count })
    end

    it "transfers the monarchy to a creature's controller when it deals combat damage to the monarch" do
      game.make_monarch!(p1)
      bear = ResolvePermanent("Grizzly Bears", owner: p2)

      game.notify!(Magic::Events::CombatDamageDealt.new(source: bear, target: p1, damage: 2))

      expect(game.monarch).to eq(p2)
    end

    it "does not transfer the monarchy when the monarch's own creature deals combat damage to them" do
      game.make_monarch!(p1)
      bear = ResolvePermanent("Grizzly Bears", owner: p1)

      game.notify!(Magic::Events::CombatDamageDealt.new(source: bear, target: p1, damage: 2))

      expect(game.monarch).to eq(p1)
    end
  end
end
