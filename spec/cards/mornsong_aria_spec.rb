# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MornsongAria do
  include_context "two player game"

  let!(:aria) { ResolvePermanent("Mornsong Aria", owner: p1) }

  it "is a legendary enchantment" do
    expect(aria.legendary?).to eq(true)
    expect(aria.enchantment?).to eq(true)
  end

  it "stops every player drawing cards" do
    hand_before = [p1, p2].map { |player| player.hand.count }
    [p1, p2].each(&:draw!)

    expect([p1, p2].map { |player| player.hand.count }).to eq(hand_before)
  end

  it "does not make a player lose for drawing from an empty library" do
    p2.library.to_a.each { |card| p2.library.remove(card) }
    p2.draw!
    game.check_state_based_actions!

    expect(p2.lost?).to eq(false)
  end

  it "stops every player gaining life" do
    p1.gain_life(3)
    p2.gain_life(3)

    expect([p1.life, p2.life]).to eq([20, 20])
  end

  it "stops life gain from an effect" do
    aria.trigger_effect(:gain_life, target: p1, life: 2)

    expect(p1.life).to eq(20)
  end

  it "lets life gain resume once it leaves the battlefield" do
    aria.put_into_graveyard!
    p1.gain_life(2)

    expect(p1.life).to eq(22)
  end

  describe "at the beginning of a player's draw step" do
    let(:wanted) { Card("Grizzly Bears", owner: p1) }

    before { p1.library.add(wanted) }

    it "makes that player lose 3 life, search for a card and put it in hand" do
      hand_before = p1.hand.count
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      game.settle!

      choice = game.choices.last
      expect(choice).to be_a(described_class::SearchChoice)
      expect(p1.life).to eq(17)
      # the draw itself was prevented
      expect(p1.hand.count).to eq(hand_before)

      game.resolve_choice!(targets: [wanted])

      expect(wanted.zone).to eq(p1.hand)
      expect(p1.hand.count).to eq(hand_before + 1)
    end

    it "also applies to the opponent's draw step, asking the opponent to search" do
      game.next_turn
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      game.settle!

      choice = game.choices.last
      expect(choice.controller).to eq(p2)
      expect(p2.life).to eq(17)
      expect(p1.life).to eq(20)
    end

    it "rejects a card that is not in the library" do
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      game.settle!

      expect { game.resolve_choice!(targets: [Card("Forest", owner: p1)]) }.to raise_error(ArgumentError)
    end
  end
end
