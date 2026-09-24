# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloomTender do
  include_context "two player game"

  let!(:tender) { ResolvePermanent("Bloom Tender", owner: p1) }

  def tap_for_mana
    p1.activate_ability(ability: tender.activated_abilities.first)
  end

  def mana_added = p1.mana_pool.select { _2.positive? }

  it "is a 1/1 Elf Druid" do
    expect([tender.power, tender.toughness]).to eq([1, 1])
    expect(tender).to be_type("Elf")
    expect(tender).to be_type("Druid")
  end

  it "adds green for itself" do
    tap_for_mana
    expect(mana_added).to eq(green: 1)
    expect(tender).to be_tapped
  end

  it "adds one mana of each color among permanents you control" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Tam, Mindful First-Year", owner: p1)
    ResolvePermanent("Liminal Hold", owner: p1)

    tap_for_mana
    expect(mana_added).to eq(green: 1, blue: 1, white: 1)
  end

  it "ignores colorless permanents and an opponent's permanents" do
    ResolvePermanent("Firdoch Core", owner: p1)
    ResolvePermanent("Liminal Hold", owner: p2)

    tap_for_mana
    expect(mana_added).to eq(green: 1)
  end
end
