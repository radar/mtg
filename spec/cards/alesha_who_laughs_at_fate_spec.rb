# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AleshaWhoLaughsAtFate do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:regrower) { Card("Elvish Regrower", owner: p1) }
  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }

  let!(:alesha) { ResolvePermanent("Alesha Who Laughs At Fate", owner: p1) }

  def attack_with_alesha
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(alesha, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 first striker" do
    expect([alesha.power, alesha.toughness]).to eq([2, 2])
    expect(alesha.has_keyword?(:first_strike)).to eq(true)
  end

  it "puts a +1/+1 counter on itself when it attacks" do
    attack_with_alesha
    game.tick!

    expect(alesha.power).to eq(3)
  end

  context "at the beginning of your end step" do
    def end_turn!
      current_turn.end!
      game.settle!
    end

    it "returns a creature card with mana value up to its power if you attacked" do
      p1.graveyard.add(bears)
      attack_with_alesha
      game.tick!
      game.settle!
      end_turn!

      expect(p1.creatures.map(&:card)).to include(bears)
    end

    it "doesn't return a card with mana value greater than its power" do
      p1.graveyard.add(regrower) # mana value 4, Alesha is 3/3 after attacking
      attack_with_alesha
      game.tick!
      end_turn!

      expect(regrower.zone).to be_graveyard
    end

    it "does nothing if you didn't attack" do
      p1.graveyard.add(bears)
      go_to_main_phase!
      end_turn!

      expect(bears.zone).to be_graveyard
    end

    it "can't return a creature card from an opponent's graveyard" do
      theirs = Card("Grizzly Bears", owner: p2)
      p2.graveyard.add(theirs)
      attack_with_alesha
      game.tick!
      end_turn!

      expect(theirs.zone).to be_graveyard
    end
  end
end
