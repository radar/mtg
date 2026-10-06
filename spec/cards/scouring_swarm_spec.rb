require 'spec_helper'

RSpec.describe Magic::Cards::ScouringSwarm do
  include_context "two player game"

  let!(:swarm) { ResolvePermanent("Scouring Swarm", owner: p1) }
  let!(:forest) { ResolvePermanent("Forest", owner: p1) }

  def insects = p1.creatures.select { |c| c.name == "Insect" }

  it "makes a tapped Insect when a land is sacrificed" do
    forest.sacrifice!
    game.settle!
    expect(insects.count).to eq(1)
    expect(insects.first).to be_tapped
  end
end
