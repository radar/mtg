# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HarshMentor do
  include_context "two player game"

  let!(:mentor) { ResolvePermanent("Harsh Mentor", owner: p1) }

  before { go_to_main_phase_for!(p2) }

  it "deals 2 damage when an opponent activates a non-mana ability of an artifact" do
    sword = ResolvePermanent("Malefic Scythe", owner: p2)
    p2.add_mana(green: 1)
    p2.activate_ability(ability: sword.activated_abilities.first) do |action|
      action.pay_mana(generic: { green: 1 })
      action.targeting(ResolvePermanent("Grizzly Bears", owner: p2))
    end
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "ignores mana abilities" do
    forest = ResolvePermanent("Forest", owner: p2)
    p2.activate_ability(ability: forest.activated_abilities.first)
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "ignores its controller's abilities" do
    go_to_main_phase_for!(p1)
    sword = ResolvePermanent("Malefic Scythe", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 1)
    p1.activate_ability(ability: sword.activated_abilities.first) do |action|
      action.pay_mana(generic: { green: 1 })
      action.targeting(bears)
    end
    game.settle!

    expect(p1.life).to eq(20)
  end
end
