# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArchwayAngel do
  include_context "two player game"

  def gate(name, owner: p1)
    ResolvePermanent(name, owner: owner)
  end

  it "is a 3/4 flying Angel" do
    angel = ResolvePermanent("Archway Angel", owner: p1)

    expect([angel.power, angel.toughness]).to eq([3, 4])
    expect(angel).to be_flying
  end

  it "gains no life with no Gates" do
    ResolvePermanent("Archway Angel", owner: p1)

    expect(p1.life).to eq(20)
  end

  it "gains 2 life for each Gate you control" do
    gate("Azorius Guildgate")
    gate("Boros Guildgate")
    ResolvePermanent("Archway Angel", owner: p1)

    expect(p1.life).to eq(24)
  end

  it "ignores the opponent's Gates and non-Gate lands" do
    gate("Azorius Guildgate", owner: p2)
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Archway Angel", owner: p1)

    expect(p1.life).to eq(20)
  end
end
