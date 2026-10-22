# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MandibularKite do
  include_context "two player game"

  let!(:kite) { ResolvePermanent("Mandibular Kite", owner: p1) }
  let(:germ) { p1.creatures.find { _1.type?("Phyrexian") } }

  it "has living weapon: a black Germ token carries it" do
    game.tick!

    expect(germ).not_to be_nil
    expect(germ.token?).to eq(true)
    expect(germ.colors).to eq([:black])
    expect(kite.attached_to).to eq(germ)
  end

  it "gives equipped creature +1/+1 and flying, so the 0/0 Germ survives as a 1/1 flyer" do
    game.tick!

    expect([germ.power, germ.toughness]).to eq([1, 1])
    expect(germ).to be_flying
  end

  it "can be moved with equip {3}{W}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_main_phase!
    p1.add_mana(white: 4)
    p1.activate_ability(ability: kite.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { white: 3 }, white: 1)
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to be_flying
    expect(p1.creatures).not_to include(germ)
  end
end
