# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LilianaWakerOfTheDead do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:liliana) { ResolvePermanent("Liliana, Waker Of The Dead", owner: p1) }

  def activate(index, &block)
    p1.activate_loyalty_ability(ability: liliana.loyalty_abilities[index], &block)
    game.stack.resolve!
    game.settle!
  end

  it "enters with 4 loyalty" do
    expect(liliana.loyalty).to eq(4)
  end

  describe "+1" do
    it "makes each player discard a card" do
      activate(0)
      game.resolve_choice!(card: p1.hand.cards.first)
      game.resolve_choice!(card: p2.hand.cards.first)

      expect(p1.graveyard.cards.count).to eq(1)
      expect(p2.graveyard.cards.count).to eq(1)
      expect(liliana.loyalty).to eq(5)
    end

    it "makes each opponent who can't discard lose 3 life" do
      [*p2.hand.cards].each { |card| p2.hand.remove(card) }
      activate(0)
      game.resolve_choice!(card: p1.hand.cards.first)

      expect(p2.life).to eq(17)
    end

    it "doesn't make you lose life when you can't discard" do
      [*p1.hand.cards].each { |card| p1.hand.remove(card) }
      activate(0)
      game.resolve_choice!(card: p2.hand.cards.first)

      expect(p1.life).to eq(20)
    end
  end

  describe "-3" do
    it "gives target creature -X/-X where X is the cards in your graveyard" do
      3.times { p1.graveyard.add(Card("Forest", owner: p1)) }
      angel = ResolvePermanent("Serra Angel", owner: p2)
      activate(1) { _1.targeting(angel) }
      game.tick!

      expect([angel.power, angel.toughness]).to eq([1, 1])
      expect(liliana.loyalty).to eq(1)
    end
  end

  describe "-7" do
    before { liliana.change_loyalty!(7) }

    it "gives you an emblem that reanimates a creature card from any graveyard at the beginning of combat" do
      activate(2)
      expect(game.emblems.count).to eq(1)

      dead = Card("Serra Angel", owner: p2)
      other = Card("Grizzly Bears", owner: p1)
      p2.graveyard.add(dead)
      p1.graveyard.add(other)
      game.notify!(Magic::Events::BeginningOfCombat.new(active_player: p1))
      game.settle!
      game.resolve_choice!(target: dead)
      game.tick!

      reanimated = p1.creatures.by_name("Serra Angel").first
      expect(reanimated).not_to be_nil
      expect(reanimated).to be_haste
    end

    it "does nothing on an opponent's turn" do
      activate(2)
      p2.graveyard.add(Card("Serra Angel", owner: p2))
      game.notify!(Magic::Events::BeginningOfCombat.new(active_player: p2))
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
