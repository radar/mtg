# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Copycrook do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_copycrook
    p1.add_mana(blue: 4)
    p1.cast(card: Card("Copycrook", owner: p1)) { _1.pay_mana(generic: { blue: 2 }, blue: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "can enter as a copy of a creature" do
    cast_copycrook
    game.resolve_choice!
    game.resolve_choice!(target: bears)
    game.settle!

    crook = p1.creatures.first
    expect(crook.name).to eq("Grizzly Bears")
    expect([crook.power, crook.toughness]).to eq([2, 2])
  end

  it "dies as a 0/0 if the copy is declined" do
    cast_copycrook
    game.skip_choice!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Copycrook")
  end

  it "connives whenever it attacks" do
    handlers = Card("Copycrook", owner: p1).event_handlers

    expect(Array(handlers[Magic::Events::FinalAttackersDeclared])).to include(Magic::TriggeredAbility::ConniveOnAttack)
  end
end
