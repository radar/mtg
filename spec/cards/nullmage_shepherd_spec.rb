# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NullmageShepherd do
  include_context "two player game"

  let!(:shepherd) { ResolvePermanent("Nullmage Shepherd", owner: p1) }
  let!(:bears) { 3.times.map { ResolvePermanent("Grizzly Bears", owner: p1) } }
  let!(:ring) { ResolvePermanent("Sol Ring", owner: p2) }
  let!(:anthem) { ResolvePermanent("Glorious Anthem", owner: p2) }

  it "is a 2/4 Elf Shaman" do
    expect(shepherd.power).to eq(2)
    expect(shepherd.toughness).to eq(4)
    expect(shepherd.type?("Elf")).to be true
    expect(shepherd.type?("Shaman")).to be true
  end

  it "taps four untapped creatures to destroy a target artifact" do
    p1.activate_ability(ability: shepherd.activated_abilities.first) do |a|
      a.pay_multi_tap([shepherd, *bears])
      a.targeting(ring)
    end
    game.stack.resolve!

    expect(shepherd).to be_tapped
    expect(bears).to all(be_tapped)
    expect(p2.graveyard.cards.map(&:name)).to include("Sol Ring")
  end

  it "destroys a target enchantment" do
    p1.activate_ability(ability: shepherd.activated_abilities.first) do |a|
      a.pay_multi_tap([shepherd, *bears])
      a.targeting(anthem)
    end
    game.stack.resolve!

    expect(p2.graveyard.cards.map(&:name)).to include("Glorious Anthem")
  end

  it "cannot target a creature" do
    expect {
      p1.activate_ability(ability: shepherd.activated_abilities.first) do |a|
        a.pay_multi_tap([shepherd, *bears])
        a.targeting(bears.first)
      end
    }.to raise_error(StandardError)
  end
end
