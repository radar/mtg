# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OldFatSpider do
  include_context "two player game"

  let!(:spider) { ResolvePermanent("Old Fat Spider", owner: p1) }

  it "is a 6/7 Spider with reach" do
    expect([spider.power, spider.toughness]).to eq([6, 7])
    expect(spider).to be_reach
  end

  context "blocking" do
    def attack_and_block(blocker)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(spider, target: p2)
      current_turn.attackers_declared!
      current_turn.declare_blocker(blocker, attacker: spider)
    end

    it "can't be blocked by a creature with power 2 or less" do
      small = ResolvePermanent("Grizzly Bears", owner: p2)

      expect { attack_and_block(small) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    end

    it "can be blocked by a creature with power 3 or more" do
      big = ResolvePermanent("Ordinary Bear", owner: p2)

      expect { attack_and_block(big) }.not_to raise_error
    end
  end

  context "when an opponent casts a spell targeting it" do
    it "draws you a card" do
      p2.add_mana(red: 1)
      action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
      action.pay_mana(red: 1)
      action.targeting(spider)
      game.take_action(action)
      game.settle!

      expect(p1.hand.count).to eq(8)
    end
  end

  context "when you target it with your own spell" do
    it "doesn't draw" do
      p1.add_mana(red: 2)
      action = cast_action(card: Card("Sure Strike", owner: p1), player: p1)
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(spider)
      game.take_action(action)

      expect(p1.hand.count).to eq(7)
    end
  end
end
