# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Personify do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:personify) { Card("Personify") }

  def cast_on(creature)
    p1.add_mana(white: 2)
    p1.cast(card: personify) do
      _1.pay_mana(generic: { white: 1 }, white: 1)
      _1.targeting(creature)
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "can only target a creature you control" do
    opposing = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 2)
    expect do
      p1.cast(card: personify) do
        _1.pay_mana(generic: { white: 1 }, white: 1)
        _1.targeting(opposing)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "exiles the creature and returns it as a new permanent" do
    cast_on(bears)

    returned = game.battlefield.creatures.find { _1.name == "Grizzly Bears" }
    expect(returned).not_to be_nil
    expect(returned).not_to equal(bears)
    expect(returned.controller).to eq(p1)
  end

  it "creates a 1/1 colorless Shapeshifter token with changeling" do
    cast_on(bears)

    token = game.battlefield.creatures.find { _1.token? }
    expect(token.name).to eq("Shapeshifter")
    expect(token.power).to eq(1)
    expect(token.toughness).to eq(1)
    expect(token.type?("Shapeshifter")).to eq(true)
    expect(token.type?("Goblin")).to eq(true)
  end
end
