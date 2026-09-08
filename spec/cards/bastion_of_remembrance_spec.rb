require "spec_helper"

RSpec.describe Magic::Cards::BastionOfRemembrance do
  include_context "two player game"

  let!(:bastion) { ResolvePermanent("Bastion of Remembrance", owner: p1) }

  it "creates a 1/1 Human Soldier when it enters" do
    expect(p1.creatures.by_name("Human Soldier").count).to eq(1)
  end

  it "drains each opponent when a creature you control dies" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    creature.destroy!

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(19)
  end
end