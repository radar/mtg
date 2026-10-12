# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpellgorgerWeird do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:weird) { ResolvePermanent("Spellgorger Weird", owner: p1) }

  def cast(name, add:, pay:)
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(**add)
    p1.cast(card:) { |a| a.pay_mana(**pay) }
    game.settle!
  end

  it "is a 2/2 Weird" do
    expect([weird.power, weird.toughness]).to eq([2, 2])
  end

  it "gets a +1/+1 counter whenever you cast a noncreature spell" do
    cast("Felidar Retreat", add: { white: 4 }, pay: { generic: { white: 3 }, white: 1 })
    game.stack.resolve!
    game.tick!

    expect([weird.power, weird.toughness]).to eq([3, 3])
  end

  it "ignores creature spells" do
    cast("Grizzly Bears", add: { green: 2 }, pay: { generic: { green: 1 }, green: 1 })
    game.tick!

    expect([weird.power, weird.toughness]).to eq([2, 2])
  end
end
