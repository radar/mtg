# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RedcapGutterDweller do
  include_context "two player game"
  before { go_to_main_phase! }

  def rats = p1.creatures.select { _1.name == "Rat" }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  it "is a 3/3 Goblin Warrior with menace" do
    redcap = ResolvePermanent("Redcap Gutter-Dweller", owner: p1)

    expect([redcap.power, redcap.toughness]).to eq([3, 3])
    expect(redcap).to be_menace
  end

  describe "when it enters" do
    it "creates two 1/1 black Rats that can't block" do
      ResolvePermanent("Redcap Gutter-Dweller", owner: p1)

      expect(rats.size).to eq(2)
      expect(rats.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
      expect(rats.first.colors).to eq([:black])
      expect(rats).to all(satisfy { _1.token? })
    end

    it "makes Rats that really can't block" do
      ResolvePermanent("Redcap Gutter-Dweller", owner: p1)
      game.next_turn
      attacker = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p1)
      current_turn.attackers_declared!

      expect { current_turn.declare_blocker(rats.first, attacker:) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    end
  end

  describe "at the beginning of your upkeep" do
    let!(:redcap) { ResolvePermanent("Redcap Gutter-Dweller", owner: p1) }
    let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def next_upkeep
      2.times { game.next_turn }
      current_turn.untap!
      current_turn.upkeep!
      game.settle!
    end

    it "may sacrifice another creature to get a counter and exile the top card, which you may play this turn" do
      top = Card("Mountain", owner: p1)
      p1.library.add(top)
      next_upkeep
      game.resolve_choice!(sacrifice: fodder)
      game.settle!

      expect(p1.creatures).not_to include(fodder)
      expect(counters(redcap)).to eq(1)
      expect(game.exile.cards).to include(top)
      expect(game.play_permissions.permits?(top, p1)).to eq(true)
    end

    it "does nothing if you decline" do
      next_upkeep
      game.skip_choice!

      expect(p1.creatures).to include(fodder)
      expect(counters(redcap)).to eq(0)
    end

    it "offers nothing when Redcap is your only creature" do
      fodder.destroy!
      rats.each(&:destroy!)
      game.settle!
      next_upkeep

      expect(game.choices).to be_empty
      expect(counters(redcap)).to eq(0)
    end

    it "doesn't let the opponent play the exiled card, and the permission ends with the turn" do
      top = Card("Mountain", owner: p1)
      p1.library.add(top)
      next_upkeep
      game.resolve_choice!(sacrifice: fodder)
      game.settle!

      expect(game.play_permissions.permits?(top, p2)).to eq(false)
      game.next_turn
      expect(game.play_permissions.permits?(top, p1)).to eq(false)
    end
  end
end
