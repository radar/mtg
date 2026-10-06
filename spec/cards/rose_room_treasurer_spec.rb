# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoseRoomTreasurer do
  include_context "two player game"

  let!(:treasurer) { ResolvePermanent("Rose Room Treasurer", owner: p1) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def enter_creature(owner: p1)
    ResolvePermanent("Grizzly Bears", owner: owner)
  end

  it "is a 4/3" do
    expect([treasurer.power, treasurer.toughness]).to eq([4, 3])
  end

  it "creates a Treasure for the first and second creature that enters in a turn" do
    enter_creature
    expect(treasures.count).to eq(1)

    enter_creature
    expect(treasures.count).to eq(2)
  end

  it "offers to pay {X} for damage instead from the third time on" do
    2.times { enter_creature }
    enter_creature

    expect(treasures.count).to eq(2)
    choice = game.choices.last
    expect(choice).to be_a(described_class::MayPayChoice)
    expect(choice.payment_cost(3)).to eq(generic: 3)
  end

  it "deals X damage to a chosen target after paying {X}" do
    2.times { enter_creature }
    enter_creature
    p1.add_mana(red: 3)

    game.resolve_choice!(x: 3, payment: { red: 3 })
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(17)
    expect(p1.mana_pool[:red]).to eq(0)
  end

  it "does nothing more when the payment is declined" do
    2.times { enter_creature }
    enter_creature
    game.skip_choice!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(20)
  end

  it "counts again from zero on a new turn" do
    2.times { enter_creature }
    game.next_turn
    game.next_turn
    enter_creature

    expect(treasures.count).to eq(3)
  end

  it "ignores an opponent's creature" do
    enter_creature(owner: p2)

    expect(treasures).to be_empty
  end
end
