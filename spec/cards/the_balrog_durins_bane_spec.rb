# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheBalrogDurinsBane do
  include_context "two player game"

  let(:balrog_card) { Card("The Balrog Durins Bane", owner: p1) }

  it "is a legendary 7/5 Avatar Demon with haste" do
    balrog = ResolvePermanent("The Balrog Durins Bane", owner: p1)

    expect([balrog.power, balrog.toughness]).to eq([7, 5])
    expect(balrog.card).to be_legendary
    expect(balrog.type?("Avatar")).to be(true)
    expect(balrog.type?("Demon")).to be(true)
    expect(balrog).to have_keyword(:haste)
  end

  describe "cost reduction" do
    before do
      go_to_main_phase!
      p1.hand.add(balrog_card)
    end

    it "costs {7} with nothing sacrificed" do
      p1.add_mana(green: 4, black: 1, red: 1)

      expect(cast_action(card: balrog_card)).not_to be_can_perform
    end

    it "costs {1} less for each permanent sacrificed this turn, by any player" do
      ResolvePermanent("Grizzly Bears", owner: p1).sacrifice!
      ResolvePermanent("Grizzly Bears", owner: p2).sacrifice!
      game.settle!
      p1.add_mana(green: 3, black: 1, red: 1)

      expect(cast_action(card: balrog_card)).to be_can_perform
    end

    it "is not reduced enough by fewer sacrifices" do
      ResolvePermanent("Grizzly Bears", owner: p1).sacrifice!
      game.settle!
      p1.add_mana(green: 3, black: 1, red: 1)

      expect(cast_action(card: balrog_card)).not_to be_can_perform
    end

    it "does not count sacrifices from an earlier turn" do
      ResolvePermanent("Grizzly Bears", owner: p1).sacrifice!
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      game.next_turn
      game.next_turn
      go_to_main_phase!
      p1.hand.add(balrog_card)
      p1.add_mana(green: 4, black: 1, red: 1)

      expect(cast_action(card: balrog_card)).not_to be_can_perform
    end
  end

  describe "blocking restriction" do
    let!(:balrog) { ResolvePermanent("The Balrog Durins Bane", owner: p1) }

    def attack!
      go_to_main_phase!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(balrog, target: p2)
      current_turn.attackers_declared!
    end

    it "can't be blocked by a nonlegendary creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      attack!

      expect(current_turn.can_block?(attacker: balrog, blocker: bears)).to eq(false)
    end

    it "can be blocked by a legendary creature" do
      elanor = ResolvePermanent("Elanor Gardner", owner: p2)
      attack!

      expect(current_turn.can_block?(attacker: balrog, blocker: elanor)).to eq(true)
    end
  end

  describe "when it dies" do
    let!(:balrog) { ResolvePermanent("The Balrog Durins Bane", owner: p1) }

    it "destroys a target artifact or creature an opponent controls" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      food = Magic::Tokens::Food.new(game: game, owner: p2).resolve!
      mine = ResolvePermanent("Raging Goblin", owner: p1)
      balrog.destroy!
      game.settle!

      expect(game.choices.first.choices.to_a).to contain_exactly(bears, food)
      game.resolve_choice!(target: food)
      game.settle!

      expect(food.zone).to be_nil
      expect(bears.zone).not_to be_nil
      expect(mine.zone).not_to be_nil
    end

    it "is mandatory" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Raging Goblin", owner: p2)
      balrog.destroy!
      game.settle!
      game.skip_choice!
      game.settle!

      expect(p2.creatures.size).to eq(1)
      expect(p2.graveyard.cards.size).to eq(1)
      expect(bears).not_to be_nil
    end

    it "cannot target a hexproof permanent" do
      big = ResolvePermanent("Gigantic Big Bear", owner: p2)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      balrog.destroy!
      game.settle!
      game.settle!

      expect(game.choices).to be_empty
      expect(big.zone).not_to be_nil
      expect(p2.graveyard.cards.map(&:name)).to eq([bears.name])
    end

    it "does nothing when the opponent has no artifact or creature" do
      balrog.destroy!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
