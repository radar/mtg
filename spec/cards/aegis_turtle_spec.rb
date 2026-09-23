# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AegisTurtle do
  include_context "two player game"

  let!(:aegis_turtle) { ResolvePermanent("Aegis Turtle", owner: p1) }

  it "is a 0/5 turtle creature" do
    expect(aegis_turtle.card.types).to include("Creature", "Turtle")
    expect(aegis_turtle.power).to eq(0)
    expect(aegis_turtle.toughness).to eq(5)
  end

  it "costs {U}" do
    expect(aegis_turtle.card.cost.blue).to eq(1)
  end
end
