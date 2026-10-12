# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChandrasMagmutt do
  include_context "two player game"

  let!(:magmutt) { ResolvePermanent("Chandra's Magmutt", owner: p1) }

  def activate(target)
    p1.activate_ability(ability: magmutt.activated_abilities.first) { _1.targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 Elemental Dog" do
    expect([magmutt.power, magmutt.toughness]).to eq([2, 2])
  end

  it "deals 1 damage to target player" do
    activate(p2)

    expect(p2.life).to eq(19)
    expect(magmutt).to be_tapped
  end

  it "deals 1 damage to target planeswalker" do
    walker = ResolvePermanent("Ob Nixilis Reignited", owner: p2)
    activate(walker)

    expect(walker.loyalty).to eq(4)
  end

  it "can't target a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    expect { activate(bears) }.to raise_error(StandardError)
  end
end
