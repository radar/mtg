# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SylvanSafekeeper do
  include_context "two player game"

  let!(:keeper) { ResolvePermanent("Sylvan Safekeeper", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:forest) { ResolvePermanent("Forest", owner: p1) }

  def ability = keeper.activated_abilities.first

  def activate(target)
    p1.activate_ability(ability: ability) do
      _1.targeting(target)
      _1.pay_sacrifice(forest)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 1/1 Human Wizard" do
    expect([keeper.power, keeper.toughness]).to eq([1, 1])
    expect(keeper.type?("Wizard")).to eq(true)
  end

  it "sacrifices a land as a cost and gives the target shroud" do
    activate(bears)
    expect(p1.graveyard.cards.map(&:name)).to include("Forest")
    expect(bears.has_keyword?(Magic::Cards::Keywords::SHROUD)).to eq(true)
  end

  it "loses shroud at end of turn" do
    activate(bears)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.has_keyword?(Magic::Cards::Keywords::SHROUD)).to eq(false)
  end

  it "cannot target a creature an opponent controls" do
    expect {
      p1.activate_ability(ability: ability) do
        _1.targeting(theirs)
        _1.pay_sacrifice(forest)
      end
    }.to raise_error(RuntimeError, /Invalid target/)
  end
end
