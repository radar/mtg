# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VolcanicSalvo do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:salvo) { Card("Volcanic Salvo", owner: p1) }

  def cast(*targets, mana:)
    p1.hand.add(salvo)
    p1.add_mana(red: mana[:generic][:red] + mana[:red])
    p1.cast(card: salvo) { |a| a.pay_mana(**mana).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 6 damage to each of two targets" do
    first = ResolvePermanent("Baneslayer Angel", owner: p2)
    second = ResolvePermanent("Serra Angel", owner: p2)

    cast(first, second, mana: { generic: { red: 10 }, red: 2 })

    expect(first.damage).to eq(6)
    expect(second.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "can target just one creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    cast(bears, mana: { generic: { red: 10 }, red: 2 })

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "costs {1} less for each point of power among your creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Baneslayer Angel", owner: p1) # 5 power
    ResolvePermanent("Grizzly Bears", owner: p1) # 2 power

    cast(bears, mana: { generic: { red: 3 }, red: 2 })

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end
end
