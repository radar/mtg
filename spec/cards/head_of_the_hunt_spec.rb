# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeadOfTheHunt do
  include_context "two player game"
  before { go_to_main_phase! }

  def wolves = p1.creatures.select { _1.name == "Wolf" }

  it "is a 4/3 Wolf with flash" do
    head = ResolvePermanent("Head Of The Hunt", owner: p1)
    expect([head.power, head.toughness]).to eq([4, 3])
    expect(head.type?("Wolf")).to eq(true)
    expect(head.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "exiles an opponent's dying creature instead and creates a 2/2 Wolf" do
    ResolvePermanent("Head Of The Hunt", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    creature.destroy!
    game.settle!

    expect(creature.card.zone).to be_exile
    expect(wolves.count).to eq(1)
    expect([wolves.first.power, wolves.first.toughness]).to eq([2, 2])
  end

  it "does not affect your own creatures" do
    ResolvePermanent("Head Of The Hunt", owner: p1)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    mine.destroy!
    game.settle!

    expect(mine.card.zone).to be_graveyard
    expect(wolves).to be_empty
  end

  it "does not replace bouncing an opponent's creature" do
    ResolvePermanent("Head Of The Hunt", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    creature.return_to_hand
    game.settle!

    expect(creature.card.zone).to be_hand
    expect(wolves).to be_empty
  end
end
