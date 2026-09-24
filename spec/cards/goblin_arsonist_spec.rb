# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinArsonist do
  include_context "two player game"

  subject(:goblin_arsonist) { ResolvePermanent("Goblin Arsonist", owner: p1) }

  it "is a 1/1 Goblin Shaman" do
    expect(goblin_arsonist.power).to eq(1)
    expect(goblin_arsonist.toughness).to eq(1)
    expect(goblin_arsonist.type?("Goblin")).to eq(true)
    expect(goblin_arsonist.type?("Shaman")).to eq(true)
  end

  context "when it dies" do
    it "presents a may choice to deal 1 damage to any target" do
      goblin_arsonist.destroy!
      game.settle!

      expect(game.choices.last).to be_a(Magic::Cards::GoblinArsonist::MayDamageChoice)
    end

    it "deals no damage when declining" do
      goblin_arsonist.destroy!
      game.settle!
      game.skip_choice!

      expect(p2.life).to eq(20)
    end

    it "deals 1 damage to the chosen player when accepting" do
      goblin_arsonist.destroy!
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(target: p2)

      expect(p2.life).to eq(19)
    end

    it "deals 1 damage to the chosen creature when accepting" do
      bear = ResolvePermanent("Grizzly Bears", owner: p2)

      goblin_arsonist.destroy!
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(target: bear)

      expect(bear.damage).to eq(1)
    end
  end
end
