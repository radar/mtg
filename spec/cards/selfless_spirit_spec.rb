# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SelflessSpirit do
  include_context "two player game"

  let!(:spirit) { ResolvePermanent("Selfless Spirit", owner: p1) }

  it "is a 2/1 flyer" do
    expect([spirit.power, spirit.toughness]).to eq([2, 1])
    expect(spirit).to be_flying
  end

  it "sacrifices itself to give your creatures indestructible until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    p1.activate_ability(ability: spirit.activated_abilities.first)
    game.stack.resolve!
    game.tick!

    expect(p1.graveyard.by_name("Selfless Spirit").count).to eq(1)
    expect(bears).to be_indestructible
    expect(theirs).not_to be_indestructible
  end
end
