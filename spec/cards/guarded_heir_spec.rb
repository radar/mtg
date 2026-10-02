# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GuardedHeir do
  include_context "two player game"

  let!(:heir) { ResolvePermanent("Guarded Heir", owner: p1) }

  it "is a 1/1 lifelinker" do
    expect([heir.power, heir.toughness]).to eq([1, 1])
    expect(heir).to be_lifelink
  end

  it "creates two 3/3 white Knight creature tokens when it enters" do
    knights = p1.creatures.select { _1.name == "Knight" }

    expect(knights.count).to eq(2)
    expect(knights.map { [_1.power, _1.toughness] }).to all(eq([3, 3]))
  end
end
