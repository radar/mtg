# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirkwoodNurturer do
  include_context "two player game"

  let!(:forest) { ResolvePermanent("Forest", owner: p1) }
  let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }

  it "is a 3/2" do
    nurturer = ResolvePermanent("Mirkwood Nurturer", owner: p1)
    game.skip_choice! while game.choices.any?
    expect(nurturer.power).to eq(3)
    expect(nurturer.toughness).to eq(2)
  end

  it "returns another permanent you control to hand and gets a +1/+1 counter" do
    nurturer = ResolvePermanent("Mirkwood Nurturer", owner: p1)
    game.resolve_choice!(target: bear)
    expect(p1.hand.cards).to include(bear.card)
    expect(p1.permanents).not_to include(bear)
    expect(nurturer.power).to eq(4)
    expect(nurturer.toughness).to eq(3)
  end

  it "gets no counter if you choose nothing" do
    nurturer = ResolvePermanent("Mirkwood Nurturer", owner: p1)
    game.skip_choice!
    expect(p1.permanents).to include(bear)
    expect(nurturer.power).to eq(3)
  end
end
