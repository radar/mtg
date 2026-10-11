# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeylineOfHope do
  include_context "two player game"

  def p1_library = [Card("Leyline Of Hope", owner: p1), *13.times.map { Card("Forest", owner: p1) }]

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # Life gained by an effect (what a card's "you gain N life" does), which replacement effects can change.
  def gain(player, amount)
    game.add_effect(Magic::Effects::GainLife.new(source: player, target: player, life: amount))
  end

  context "when begun on the battlefield" do
    before do
      game.resolve_choice!
      game.settle!
    end

    it "is on the battlefield" do
      expect(p1.permanents.map(&:name)).to include("Leyline of Hope")
    end

    it "makes you gain one more life than you would" do
      gain(p1, 3)
      game.settle!

      expect(p1.life).to eq(24)
    end

    it "doesn't change life gained by your opponent" do
      gain(p2, 3)
      game.settle!

      expect(p2.life).to eq(23)
    end

    it "gives your creatures +2/+2 with at least 7 life more than your starting life" do
      gain(p1, 5) # 20 + 5 + 1 = 26
      game.tick!
      expect(bears.power).to eq(2)

      gain(p1, 1) # + 2 = 28
      game.tick!
      expect([bears.power, bears.toughness]).to eq([4, 4])
    end

    it "loses the bonus when your life drops again" do
      gain(p1, 6)
      game.tick!
      p1.lose_life(5)
      game.tick!

      expect(bears.power).to eq(2)
    end

    it "doesn't buff your opponent's creatures" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      gain(p1, 10)
      game.tick!

      expect(theirs.power).to eq(2)
    end
  end

  it "does nothing if it stays in hand" do
    game.skip_choice!
    gain(p1, 3)
    game.settle!

    expect(p1.life).to eq(23)
  end
end
