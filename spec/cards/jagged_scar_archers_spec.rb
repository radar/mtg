# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JaggedScarArchers do
  include_context "two player game"

  let!(:archers) { ResolvePermanent("Jagged-Scar Archers", owner: p1) }

  it "has power and toughness equal to the number of Elves you control" do
    game.tick!
    expect(archers.power).to eq(1)
    expect(archers.toughness).to eq(1)

    ResolvePermanent("Elvish Warmaster", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Elvish Warmaster", owner: p2)
    game.tick!

    expect(archers.power).to eq(2)
    expect(archers.toughness).to eq(2)
  end

  context "{T}: deals damage equal to its power to target creature with flying" do
    let!(:flyer) { ResolvePermanent("Aven Gagglemaster", owner: p2) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      ResolvePermanent("Elvish Warmaster", owner: p1)
      game.tick!
    end

    it "damages the flying creature" do
      p1.activate_ability(ability: archers.activated_abilities.first) { _1.targeting(flyer) }
      game.stack.resolve!

      expect(flyer.damage).to eq(2)
      expect(archers).to be_tapped
    end

    it "cannot target a creature without flying" do
      expect {
        p1.activate_ability(ability: archers.activated_abilities.first) { _1.targeting(bears) }
      }.to raise_error(StandardError)
    end
  end
end
