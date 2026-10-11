# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LightUpTheStage do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Light Up The Stage", owner: p1).tap { p1.hand.add(_1) } }

  def top_two = p1.library.cards.first(2)

  it "exiles the top two cards and lets you play them" do
    exiled = top_two
    p1.add_mana(red: 3)
    p1.cast(card: spell) { _1.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!

    expect(exiled.map(&:zone)).to all(be_exile)
    expect(exiled.all? { game.play_permissions.permits?(_1, p1) }).to be(true)
  end

  it "lasts through the end of your next turn" do
    exiled = top_two
    p1.add_mana(red: 3)
    p1.cast(card: spell) { _1.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    go_to_main_phase_for!(p2)
    expect(game.play_permissions.permits?(exiled.first, p1)).to be(true)
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p1)
    expect(game.play_permissions.permits?(exiled.first, p1)).to be(true)
  end

  describe "spectacle {R}" do
    it "can't be cast for {R} if no opponent lost life this turn" do
      p1.add_mana(red: 1)

      expect { p1.cast_as(:spectacle, card: spell) { _1.pay_mana(red: 1) } }.to raise_error(Magic::IllegalAction)
    end

    it "costs {R} once an opponent lost life this turn" do
      p2.lose_life(1)
      p1.add_mana(red: 1)
      p1.cast_as(:spectacle, card: spell) { _1.pay_mana(red: 1) }
      game.stack.resolve!

      expect(spell.zone).to be_graveyard
      expect(top_two.size).to eq(2)
    end

    it "doesn't count your own life loss" do
      p1.lose_life(2)
      p1.add_mana(red: 1)

      expect { p1.cast_as(:spectacle, card: spell) { _1.pay_mana(red: 1) } }.to raise_error(Magic::IllegalAction)
    end
  end
end
