# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarvinMurderousMimic do
  include_context "two player game"

  let!(:marvin) { ResolvePermanent("Marvin, Murderous Mimic", owner: p1) }

  def ability_classes(permanent) = permanent.activated_abilities.map(&:class)

  it "is a 2/2 legendary artifact creature Toy" do
    expect(marvin.power).to eq(2)
    expect(marvin.toughness).to eq(2)
    expect(marvin).to be_artifact
    expect(marvin.types).to include("Toy")
  end

  it "has no abilities when you control no other creatures with activated abilities" do
    game.tick!
    expect(ability_classes(marvin)).to be_empty
  end

  it "has the activated abilities of your other creatures" do
    ResolvePermanent("Humble Defector", owner: p1)
    game.tick!
    expect(ability_classes(marvin)).to include(Magic::Cards::HumbleDefector::DrawAndGiveControl)
  end

  it "does not copy abilities from creatures an opponent controls" do
    ResolvePermanent("Humble Defector", owner: p2)
    game.tick!
    expect(ability_classes(marvin)).to be_empty
  end

  it "stops having the ability when the creature leaves" do
    defector = ResolvePermanent("Humble Defector", owner: p1)
    game.tick!
    defector.destroy!
    game.settle!
    game.tick!
    expect(ability_classes(marvin)).to be_empty
  end
end
