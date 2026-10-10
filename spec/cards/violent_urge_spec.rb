# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ViolentUrge do
  include_context "two player game"

  let(:card) { Card("Violent Urge", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(card)
    p1.add_mana(red: 1)
  end

  def cast_on(creature)
    p1.cast(card:) { |a| a.pay_mana(red: 1).targeting(creature) }
    game.stack.resolve!
    game.tick!
  end

  it "gives the creature +1/+0 and first strike until end of turn" do
    cast_on(bears)

    expect([bears.power, bears.toughness]).to eq([3, 2])
    expect(bears.first_strike?).to be(true)
    expect(bears.double_strike?).to be(false)

    game.current_turn.end!
    game.current_turn.cleanup!
    game.tick!

    expect(bears.power).to eq(2)
    expect(bears.first_strike?).to be(false)
  end

  it "also grants double strike with delirium" do
    # land, creature, instant, artifact
    ["Island", "Grizzly Bears", "Sure Strike", "Haunted Screen"].each do |name|
      p1.graveyard.add(Card(name, owner: p1))
    end
    expect(p1.graveyard.delirium?).to be(true)

    cast_on(bears)

    expect(bears.first_strike?).to be(true)
    expect(bears.double_strike?).to be(true)
  end
end
