# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaalfeldTwins do
  include_context "two player game"

  let!(:twins) { ResolvePermanent("Maalfeld Twins", owner: p1) }

  it "is a 4/4 Zombie" do
    expect([twins.power, twins.toughness]).to eq([4, 4])
  end

  it "creates two 2/2 black Zombie tokens when it dies" do
    twins.destroy!
    game.settle!
    zombies = p1.creatures.select { _1.name == "Zombie" }

    expect(zombies.count).to eq(2)
    expect(zombies.map { [_1.power, _1.toughness] }).to all(eq([2, 2]))
  end
end
