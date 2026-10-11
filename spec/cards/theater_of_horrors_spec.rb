# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheaterOfHorrors do
  include_context "two player game"

  let!(:theater) { ResolvePermanent("Theater Of Horrors", owner: p1) }

  def upkeep!
    current_turn.untap!
    current_turn.upkeep!
    game.settle!
  end

  it "exiles the top card of your library at your upkeep" do
    top = p1.library.first
    upkeep!

    expect(top.zone).to be_exile
    expect(theater.exiled_cards).to include(top)
  end

  it "doesn't trigger on the opponent's upkeep" do
    game.next_turn
    top = p1.library.first
    upkeep!

    expect(p1.library.first).to equal(top)
  end

  describe "playing the exiled cards" do
    let(:bears) { Card("Grizzly Bears", owner: p1) }
    let(:forest) { Card("Forest", owner: p1) }

    before do
      p1.library.add(bears)
      upkeep!
      current_turn.draw!
      current_turn.first_main!
    end

    it "can't be cast before an opponent lost life this turn" do
      p1.add_mana(green: 2)

      expect { p1.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(Magic::IllegalAction)
    end

    it "can be cast once an opponent lost life this turn" do
      p2.lose_life(1)
      p1.add_mana(green: 2)
      p1.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end
  end

  it "deals 1 damage to target opponent for {3}{R}" do
    p1.add_mana(red: 4)
    p1.activate_ability(ability: theater.activated_abilities.first) do |action|
      action.pay_mana(generic: { red: 3 }, red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(19)
  end
end
