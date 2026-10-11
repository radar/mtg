# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MogisGodOfSlaughter do
  include_context "two player game"

  let!(:mogis) { ResolvePermanent("Mogis God Of Slaughter", owner: p1) }

  def opponent_upkeep!
    game.next_turn
    current_turn.untap!
    current_turn.upkeep!
    game.settle!
  end

  it "is indestructible" do
    expect(mogis).to have_keyword(:indestructible)
  end

  describe "devotion to black and red" do
    it "isn't a creature below seven" do
      expect(mogis).to be_enchantment
      expect(mogis).not_to be_creature
    end

    it "is a 7/5 creature at seven or more" do
      # Mogis {2}{B}{R} is 2; three more cards of two coloured symbols reach 8.
      3.times { ResolvePermanent("Falkenrath Noble", owner: p1) } # {3}{B} each: 1 symbol
      2.times { ResolvePermanent("Stormfist Crusader", owner: p1) } # {B}{R}: 2 symbols
      game.tick!

      expect(mogis).to be_creature
      expect([mogis.power, mogis.toughness]).to eq([7, 5])
    end
  end

  describe "at an opponent's upkeep" do
    it "deals 2 damage if they decline to sacrifice a creature" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      opponent_upkeep!
      game.skip_choice!
      game.settle!

      expect(p2.life).to eq(18)
    end

    it "lets them sacrifice a creature of their choice instead" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      other = ResolvePermanent("Grizzly Bears", owner: p2)
      opponent_upkeep!
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(bears.zone).to be_nil
      expect(other.zone).to be_battlefield
      expect(p2.life).to eq(20)
    end

    it "deals 2 damage straight away when they have no creature" do
      opponent_upkeep!

      expect(p2.life).to eq(18)
    end

    it "doesn't trigger on its controller's upkeep" do
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(p1.life).to eq(20)
    end
  end
end
