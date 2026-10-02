# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonTrainer do
  include_context "two player game"

  it "is a 1/1 Human" do
    trainer = ResolvePermanent("Dragon Trainer", owner: p1)

    expect([trainer.power, trainer.toughness]).to eq([1, 1])
  end

  it "creates a 4/4 red Dragon token with flying when it enters" do
    ResolvePermanent("Dragon Trainer", owner: p1)
    dragon = p1.creatures.find { _1.name == "Dragon" }

    expect([dragon.power, dragon.toughness]).to eq([4, 4])
    expect(dragon).to be_flying
  end
end
