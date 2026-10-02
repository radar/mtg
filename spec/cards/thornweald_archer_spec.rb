# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThornwealdArcher do
  include_context "two player game"

  it "is a 2/1 Elf Archer with reach and deathtouch" do
    archer = ResolvePermanent("Thornweald Archer", owner: p1)

    expect([archer.power, archer.toughness]).to eq([2, 1])
    expect(archer).to be_reach
    expect(archer).to be_deathtouch
  end
end
