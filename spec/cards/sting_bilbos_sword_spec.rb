# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StingBilbosSword do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Ordinary Bear", owner: p1) }

  def hone_counters(sting) = sting.counters.of_type(Magic::Counters::Hone).count

  it "puts a hone counter on itself for each creature the opponent controls when it enters" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p2) }
    sting = ResolvePermanent("Sting Bilbos Sword", owner: p1)

    expect(hone_counters(sting)).to eq(2)
  end

  it "may attach to a creature you control as it enters, which then gets +1/+0 per hone counter" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p2) }
    sting = ResolvePermanent("Sting Bilbos Sword", owner: p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(sting.attached_to).to eq(bears)
    expect([bears.power, bears.toughness]).to eq([4, 2])
  end

  it "can decline to attach" do
    sting = ResolvePermanent("Sting Bilbos Sword", owner: p1)
    game.skip_choice!

    expect(sting.attached_to).to be_nil
  end

  it "has no counters when the opponent controls no creatures" do
    sting = ResolvePermanent("Sting Bilbos Sword", owner: p1)

    expect(hone_counters(sting)).to eq(0)
  end

  it "can be cast with flash" do
    go_to_main_phase_for!(p2)
    sting = Card("Sting Bilbos Sword", owner: p1)
    p1.hand.add(sting)
    p1.add_mana(colorless: 2)

    expect { p1.cast(card: sting) { _1.pay_mana(generic: { colorless: 2 }) } }.not_to raise_error
  end

  it "equips for {3}" do
    sting = ResolvePermanent("Sting Bilbos Sword", owner: p1)
    game.skip_choice!
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: sting.activated_abilities.first) do
      _1.targeting(other)
      _1.pay_mana(generic: { colorless: 3 })
    end
    game.stack.resolve!
    game.tick!

    expect(sting.attached_to).to eq(other)
  end
end
