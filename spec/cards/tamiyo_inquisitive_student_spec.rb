# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TamiyoInquisitiveStudent do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:tamiyo) { ResolvePermanent("Tamiyo, Inquisitive Student", owner: p1) }

  def walker = game.battlefield.controlled_by(p1).find { _1.name == "Tamiyo, Seasoned Scholar" }

  it "has flying" do
    expect(tamiyo).to have_keyword(:flying)
  end

  it "investigates when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: tamiyo, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
    expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Clue")
  end

  it "transforms when its controller draws a third card in a turn" do
    draws = current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == p1 }
    (2 - draws).times { p1.draw! }
    game.settle!
    expect(walker).to be_nil
    p1.draw!
    game.settle!
    expect(walker).to be_planeswalker
    expect(walker.loyalty).to eq(2)
  end

  it "ignores a third card drawn by the opponent" do
    3.times { p2.draw! }
    game.settle!
    expect(walker).to be_nil
  end

  context "as a planeswalker" do
    let!(:walker) do
      tamiyo.exile_and_return_transformed!
      game.settle!
      game.battlefield.controlled_by(p1).find { _1.name == "Tamiyo, Seasoned Scholar" }
    end

    def activate(index, &block)
      p1.activate_loyalty_ability(ability: walker.loyalty_abilities[index], &block)
      game.stack.resolve!
      game.settle!
    end

    it "-3 returns an instant or sorcery card from the graveyard" do
      walker.change_loyalty!(1)
      shock = Card("Shock", owner: p1)
      p1.graveyard.add(shock)
      activate(1) { _1.targeting(shock) }
      expect(p1.hand.cards).to include(shock)
      expect(game.choices).to be_empty
    end

    it "-3 offers mana for a green card" do
      walker.change_loyalty!(1)
      growth = Card("Rangers Guile", owner: p1)
      p1.graveyard.add(growth)
      activate(1) { _1.targeting(growth) }
      expect(p1.hand.cards).to include(growth)
      game.resolve_choice!(mode: :green)
      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "-7 draws half the library, rounded up, and removes the hand size limit" do
      walker.change_loyalty!(5)
      9.times { p1.library.add(Card("Island", owner: p1)) }
      expected = (p1.library.count / 2.0).ceil
      hand = p1.hand.count
      activate(2)
      expect(p1.hand.count).to eq(hand + expected)
      expect(p1.maximum_hand_size).to be_nil
    end

    def attack_with(attacker, target)
      go_to_main_phase_for!(p2)
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      p2.declare_attacker(attacker: attacker, target: target)
      current_turn.attackers_declared!
      game.settle!
      game.stack.resolve!
      game.settle!
    end

    it "+2 shrinks creatures attacking its controller" do
      activate(0)
      expect(walker.loyalty).to eq(4)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      game.next_turn
      attack_with(bears, p1)
      expect(bears.power).to eq(1)
    end

    it "+2 shrinks creatures attacking a planeswalker its controller controls" do
      other = ResolvePermanent("Liliana, Waker Of The Dead", owner: p1)
      activate(0)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      game.next_turn
      attack_with(bears, other)
      expect(bears.power).to eq(1)
    end

    it "+2 still applies after Tamiyo leaves the battlefield" do
      activate(0)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      walker.destroy!
      game.settle!
      game.next_turn
      attack_with(bears, p1)
      expect(bears.power).to eq(1)
    end

    it "+2 ends when its controller's next turn begins" do
      activate(0)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      2.times { game.next_turn }
      expect(current_turn.active_player).to eq(p1)
      go_to_main_phase!
      game.next_turn
      attack_with(bears, p1)
      expect(bears.power).to eq(2)
    end
  end
end
