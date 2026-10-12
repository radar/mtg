# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HelmOfTheHost do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:helm) { ResolvePermanent("Helm Of The Host", owner: p1) }
  let!(:jazal) { ResolvePermanent("Jazal Goldmane", owner: p1) } # legendary 4/4

  def equip(creature)
    p1.add_mana(red: 5)
    p1.activate_ability(ability: helm.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 5 })
      a.targeting(creature)
    end
    game.stack.resolve!
  end

  def beginning_of_combat
    current_turn.beginning_of_combat!
    game.settle!
  end

  def copies = p1.creatures.select { _1.name == "Jazal Goldmane" && _1.token? }

  it "is a legendary artifact Equipment" do
    expect(helm.type?("Equipment")).to be true
    expect(helm.legendary?).to be true
  end

  it "does nothing while it equips nothing" do
    beginning_of_combat

    expect(copies).to be_empty
  end

  it "makes a token copy of the equipped creature at the beginning of combat on your turn" do
    equip(jazal)
    beginning_of_combat

    expect(copies.count).to eq(1)
    expect([copies.first.power, copies.first.toughness]).to eq([4, 4])
    expect(copies.first).to have_keyword(:first_strike)
  end

  it "makes a copy that isn't legendary and has haste, so the legend rule leaves both" do
    equip(jazal)
    beginning_of_combat
    game.tick!

    expect(copies.first.legendary?).to be false
    expect(copies.first).to have_keyword(:haste)
    expect(jazal.zone).to be_a(Magic::Zones::Battlefield)
    expect(p1.creatures).to include(jazal, copies.first)
  end

  it "doesn't trigger on the opponent's turn" do
    equip(jazal)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!

    expect(copies).to be_empty
  end
end
