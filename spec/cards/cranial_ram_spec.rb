# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CranialRam do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:ram) { ResolvePermanent("Cranial Ram", owner: p1) }

  def germ = p1.creatures.find { _1.name == "Phyrexian Germ" }

  it "creates a Germ and attaches to it" do
    game.settle!
    expect(germ).not_to be_nil
    expect(ram.attached_to).to eq(germ)
  end

  it "gives +X/+1 where X is the number of artifacts you control" do
    game.settle!
    game.tick!
    expect(germ.power).to eq(1) # the Ram itself
    expect(germ.toughness).to eq(1)

    ResolvePermanent("Annex Sentry", owner: p1)
    game.tick!
    expect(germ.power).to eq(2)
  end

  it "does not count an opponent's artifacts" do
    game.settle!
    ResolvePermanent("Annex Sentry", owner: p2)
    game.tick!
    expect(germ.power).to eq(1)
  end

  it "can be equipped for {2}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    p1.add_mana(red: 2)
    p1.activate_ability(ability: ram.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { red: 2 })
    end
    game.stack.resolve!
    game.tick!
    expect(bears.power).to eq(3) # 2 + 1 artifact
    expect(bears.toughness).to eq(3)
  end
end
