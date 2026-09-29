# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MudbuttonCursetosser do
  include_context "two player game"

  let!(:cursetosser) { ResolvePermanent("Mudbutton Cursetosser", owner: p1) }

  it "is a 2/1 Goblin Warlock" do
    expect([cursetosser.power, cursetosser.toughness]).to eq([2, 1])
    expect(cursetosser.type?("Goblin")).to eq(true)
  end

  describe "the additional cost" do
    let(:card) { Card("Mudbutton Cursetosser", owner: p1) }

    before do
      p1.hand.add(card)
      go_to_main_phase!
    end

    it "can behold a Goblin you control" do
      p1.add_mana(black: 1)
      p1.cast(card: card) { |a| a.pay_mana(black: 1).pay_behold(cursetosser) }
      game.stack.resolve!
      expect(card.zone).to be_battlefield
    end

    it "can pay {2} instead" do
      p1.add_mana(black: 3)
      p1.cast(card: card) { |a| a.pay_mana(black: 1).pay_behold(generic: { black: 2 }) }
      game.stack.resolve!
      expect(card.zone).to be_battlefield
    end
  end

  it "can't block" do
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    game.next_turn
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    current_turn.attackers_declared!

    expect(current_turn.can_block?(attacker: attacker, blocker: cursetosser)).to eq(false)
    expect { current_turn.declare_blocker(cursetosser, attacker: attacker) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  describe "when it dies" do
    it "destroys target creature an opponent controls with power 2 or less" do
      small = ResolvePermanent("Grizzly Bears", owner: p2)
      cursetosser.destroy!
      game.settle!

      expect(small.zone).to be_nil
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "can't pick a creature with greater power, or one you control" do
      big = ResolvePermanent("Baneslayer Angel", owner: p2)
      own = ResolvePermanent("Grizzly Bears", owner: p1)
      cursetosser.destroy!
      game.settle!

      expect(game.choices).to be_empty
      expect(big.zone).to be_battlefield
      expect(own.zone).to be_battlefield
    end

    it "asks which one when several qualify" do
      2.times { ResolvePermanent("Grizzly Bears", owner: p2) }
      cursetosser.destroy!
      game.settle!
      expect(game.choices.last.choices.count).to eq(2)
    end
  end
end
