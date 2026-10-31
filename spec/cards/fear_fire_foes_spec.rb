# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearFireFoes do
  include_context "two player game"

  let!(:target) { ResolvePermanent("Serra Angel", owner: p2) }
  let!(:bystander) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { go_to_main_phase! }

  def cast_fff(x:, on: target)
    card = Card("Fear Fire Foes", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: x + 1)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { red: x }, red: 1).targeting(on) }
    game.stack.resolve!
    game.settle!
  end

  it "deals X damage to the target and 1 damage to each other creature with the same controller" do
    cast_fff(x: 3)

    expect(target.damage).to eq(3)
    expect(bystander.damage).to eq(1)
  end

  it "does not damage creatures controlled by someone else" do
    cast_fff(x: 3)

    expect(mine.damage).to eq(0)
  end

  it "kills a target dealt lethal damage" do
    cast_fff(x: 4)

    expect(p2.graveyard.cards.map(&:name)).to include("Serra Angel")
    expect(p2.creatures).to include(bystander)
  end

  it "deals only 1 damage to others when X is 0" do
    cast_fff(x: 0)

    expect(target.damage).to eq(0)
    expect(bystander.damage).to eq(1)
  end

  it "can't be cast targeting a hexproof creature" do
    shark = ResolvePermanent("Spined Megalodon", owner: p2)

    expect { cast_fff(x: 1, on: shark) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "makes damage unpreventable this turn" do
    bystander.gains_protection_from_color(:red, until_eot: true)
    cast_fff(x: 3)

    expect(bystander.damage).to eq(1)
    expect(game.current_turn.damage_cant_be_prevented?).to be(true)
  end

  it "leaves damage preventable on later turns" do
    cast_fff(x: 1)
    game.next_turn

    expect(game.current_turn.damage_cant_be_prevented?).to be(false)
  end

  it "prevents damage normally without the spell" do
    bystander.gains_protection_from_color(:red, until_eot: true)
    source = Card("Fear Fire Foes", owner: p1)
    game.add_effect(Magic::Effects::DealDamage.new(source:, target: bystander, damage: 1))

    expect(bystander.damage).to eq(0)
  end
end
