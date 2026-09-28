# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrystansCommand do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:command) { Card("Trystans Command", owner: p1) }

  def cast_with(*modes)
    p1.hand.add(command)
    p1.add_mana(black: 1, green: 5)
    p1.cast(card: command) do |action|
      action.pay_mana(black: 1, green: 1, generic: { green: 4 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.tick!
  end

  it "returns up to two permanent cards from your graveyard and destroys a creature" do
    a = Card("Grizzly Bears", owner: p1)
    b = Card("Forest", owner: p1)
    p1.graveyard.add(a)
    p1.graveyard.add(b)
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_with([described_class::Return, a, b], [described_class::Destroy, victim])

    expect(p1.hand.cards).to include(a, b)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "gives a player's creatures +3/+3 and untaps them, and copies an Elf" do
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    elf.tap!
    cast_with([described_class::PumpAndUntap, p1], [described_class::CopyElf, elf])

    expect(elf.power).to eq(4)
    expect(elf).not_to be_tapped
    expect(p1.creatures.count { _1.name == "Llanowar Elves" }).to eq(2)
  end
end
