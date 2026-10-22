# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WheelOfPotential do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Wheel of Potential", owner: p1).tap { p1.hand.add(_1) } }
  let!(:mine) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }
  let!(:theirs) { Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) } }

  def cast!
    p1.add_mana(red: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "gives you three energy, then asks how much to pay" do
    cast!

    expect(p1.energy).to eq(3)
    expect(game.choices.first).to be_a(Magic::Choice::PayAnyEnergy)
  end

  it "lets each player exile their hand and draw that many cards" do
    cast!
    game.resolve_choice!(amount: 2)
    game.resolve_choice!
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(1)
    expect(mine.zone).to be_exile
    expect(theirs.zone).to be_exile
    expect(p1.hand.count).to eq(2)
    expect(p2.hand.count).to eq(2)
  end

  it "asks you first and your opponent second" do
    cast!
    game.resolve_choice!(amount: 1)

    expect(game.choices.first.chooser).to eq(p1)
    game.skip_choice!
    expect(game.choices.first.chooser).to eq(p2)
  end

  it "leaves a hand alone when that player declines" do
    cast!
    game.resolve_choice!(amount: 2)
    game.resolve_choice!
    game.skip_choice!
    game.settle!

    expect(mine.zone).to be_exile
    expect(theirs.zone).to be_hand
    expect(p2.hand).to include(theirs)
  end

  it "draws nothing and keeps all energy when you decline to pay" do
    cast!
    game.skip_choice!
    game.skip_choice!
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(3)
    expect(mine.zone).to be_hand
    expect(theirs.zone).to be_hand
  end

  it "can't pay more energy than you have" do
    cast!
    game.resolve_choice!(amount: 10)
    game.skip_choice!
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(0)
  end

  context "when seven or more energy was paid" do
    before do
      p1.add_counter("energy", amount: 4)
      cast!
      game.resolve_choice!(amount: 7)
      game.resolve_choice!
      game.resolve_choice!
      game.settle!
    end

    it "lets you play your exiled cards, but not your opponent's" do
      expect(mine.zone).to be_exile
      p1.add_mana(green: 2)
      p1.cast(card: mine) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
      game.settle!

      expect(mine.zone).to be_nil.or be_battlefield
      expect(game.battlefield.permanents.map(&:name)).to include("Grizzly Bears")
      expect(theirs.zone).to be_exile
      expect(game.play_permissions.permits?(theirs, p2)).to be(false)
    end

    it "lasts until the end of your next turn" do
      expect(game.play_permissions.permits?(mine, p1)).to be(true)
      game.next_turn
      expect(game.play_permissions.permits?(mine, p1)).to be(true)
      game.next_turn
      expect(game.play_permissions.permits?(mine, p1)).to be(true)
      game.next_turn
      expect(game.play_permissions.permits?(mine, p1)).to be(false)
    end
  end

  it "grants no permission when fewer than seven energy was paid" do
    p1.add_counter("energy", amount: 3)
    cast!
    game.resolve_choice!(amount: 6)
    game.resolve_choice!
    game.skip_choice!
    game.settle!

    expect(mine.zone).to be_exile
    expect(game.play_permissions.permits?(mine, p1)).to be(false)
  end
end
