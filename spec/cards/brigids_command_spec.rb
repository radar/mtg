# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrigidsCommand do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:command) { Card("Brigids Command", owner: p1) }

  def cast_with(*modes)
    p1.hand.add(command)
    p1.add_mana(green: 2, white: 1)
    p1.cast(card: command) do |action|
      action.pay_mana(green: 1, white: 1, generic: { green: 1 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.tick!
  end

  it "copies a Kithkin you control and gives +3/+3" do
    kithkin = ResolvePermanent("Wary Farmer", owner: p1)
    cast_with([described_class::CopyKithkin, kithkin], [described_class::Pump, kithkin])

    expect(p1.creatures.count { _1.name == "Wary Farmer" }).to eq(2)
    expect(kithkin.power).to eq(6)
  end

  it "makes the target player a 1/1 Kithkin and fights" do
    mine = ResolvePermanent("Wary Farmer", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_with([described_class::CreateKithkin, p2], [described_class::Fight, mine, theirs])

    token = p2.creatures.find(&:token?)
    expect(token.name).to eq("Kithkin")
    expect(token.colors).to contain_exactly(:green, :white)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(mine.damage).to eq(2)
  end
end
