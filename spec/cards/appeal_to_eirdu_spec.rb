# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AppealToEirdu do
  include_context "two player game"

  let(:card) { Card("Appeal To Eirdu", owner: p1) }

  def cast_on(*targets)
    p1.hand.add(card)
    p1.add_mana(white: 4)
    p1.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 1).targeting(*targets) }
    game.stack.resolve!
    game.tick!
  end

  it "has convoke" do
    expect(card.convoke?).to be(true)
  end

  it "can be cast by tapping creatures" do
    helpers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
    p1.hand.add(card)
    p1.add_mana(white: 2)
    p1.cast(card:) do |action|
      helpers.each { action.convoke(_1) }
      action.pay_mana(generic: { white: 1 }, white: 1).targeting(helpers.first)
    end

    expect(helpers).to all(be_tapped)
  end

  it "gives one target creature +2/+1 until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(bears)

    expect([bears.power, bears.toughness]).to eq([4, 3])
  end

  it "gives each of two target creatures +2/+1" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(mine, theirs)

    expect([mine, theirs].map { [_1.power, _1.toughness] }).to all(eq([4, 3]))
  end

  it "leaves other creatures alone" do
    bystander = ResolvePermanent("Grizzly Bears", owner: p2)
    target = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(target)

    expect(bystander.power).to eq(2)
  end
end
