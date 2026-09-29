# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OmniChangeling do
  include_context "two player game"

  let!(:target) { ResolvePermanent("Shinestriker", owner: p2) } # 3/3 flying Elemental
  let(:card) { Card("Omni-Changeling", owner: p1) }

  def enter_as_copy_of(creature)
    omni = ResolvePermanent("Omni-Changeling", owner: p1)
    game.resolve_choice!
    game.resolve_choice!(target: creature)
    game.tick!
    omni
  end

  it "has convoke and changeling" do
    expect(card.convoke?).to be(true)
    expect(card).to be_changeling
  end

  it "may enter as a copy of any creature on the battlefield" do
    omni = enter_as_copy_of(target)

    expect(omni.name).to eq("Shinestriker")
    expect([omni.power, omni.toughness]).to eq([3, 3])
    expect(omni).to be_flying
    expect(omni.zone).to be_battlefield
  end

  it "except it has changeling: it is every creature type" do
    omni = enter_as_copy_of(target)

    expect(omni.type?("Elf")).to be(true)
    expect(omni.type?("Goblin")).to be(true)
  end

  it "stays a 0/0 changeling (and dies) when you decline" do
    omni = ResolvePermanent("Omni-Changeling", owner: p1)
    game.skip_choice!
    game.settle!

    expect(game.battlefield.permanents).not_to include(omni)
  end

  it "can copy your own creature" do
    mine = ResolvePermanent("Courser Of Kruphix", owner: p1)
    omni = enter_as_copy_of(mine)

    expect([omni.power, omni.toughness]).to eq([2, 4])
  end

  it "can be cast with convoke" do
    go_to_main_phase!
    helpers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
    p1.hand.add(card)
    p1.add_mana(blue: 3)
    p1.cast(card:) do |action|
      helpers.each { action.convoke(_1) }
      action.pay_mana(generic: { blue: 1 }, blue: 2)
    end
    game.stack.resolve!

    expect(helpers).to all(be_tapped)
    expect(game.choices.last).to be_a(described_class::MayCopyChoice)
  end
end
