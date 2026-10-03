# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MassacreWurm do
  include_context "two player game"

  it "is a 6/5 Phyrexian Wurm" do
    wurm = ResolvePermanent("Massacre Wurm", owner: p1)

    expect([wurm.power, wurm.toughness]).to eq([6, 5])
  end

  context "when it enters" do
    it "gives creatures your opponents control -2/-2 until end of turn" do
      angel = ResolvePermanent("Serra Angel", owner: p2)
      ResolvePermanent("Massacre Wurm", owner: p1)
      game.settle!

      expect([angel.power, angel.toughness]).to eq([2, 2])
    end

    it "kills opponent creatures that drop to 0 toughness" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Massacre Wurm", owner: p1)
      game.settle!

      expect(p2.creatures).not_to include(bears)
    end

    it "does not shrink your own creatures" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Massacre Wurm", owner: p1)
      game.settle!

      expect([mine.power, mine.toughness]).to eq([2, 2])
    end

    it "wears off at end of turn" do
      angel = ResolvePermanent("Serra Angel", owner: p2)
      ResolvePermanent("Massacre Wurm", owner: p1)
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect([angel.power, angel.toughness]).to eq([4, 4])
    end

    it "makes the opponent lose 2 life for each of their creatures that dies" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Massacre Wurm", owner: p1)
      game.settle!

      expect(p2.life).to eq(16)
      expect(p1.life).to eq(20)
    end
  end

  it "drains the opponent when their creature dies later" do
    ResolvePermanent("Massacre Wurm", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs.destroy!
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "does not drain when your own creature dies" do
    ResolvePermanent("Massacre Wurm", owner: p1)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    mine.destroy!
    game.settle!

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end
end
