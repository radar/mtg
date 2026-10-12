# frozen_string_literal: true

require "spec_helper"

# A UI lists a planeswalker's abilities by what they do ("[+1]: Create three 1/1 white Soldier creature tokens."), not by
# class name ("[+1]: Loyalty Ability1").
RSpec.describe Magic::LoyaltyAbility, "#description" do
  include_context "two player game"

  it "is nil unless the card says what the ability does" do
    expect(described_class.allocate.description).to be_nil
  end

  it "is written out for every loyalty ability of every planeswalker card" do
    planeswalkers = Magic::Cards.constants.map { Magic::Cards.const_get(_1) }.select { _1.is_a?(Class) && _1 < Magic::Cards::Planeswalker }
    expect(planeswalkers).not_to be_empty

    missing = planeswalkers.flat_map do |card_class|
      card_class.allocate.loyalty_abilities
                .select { |ability| ability.instance_method(:description).owner == described_class }
                .map { |ability| "#{card_class.name.demodulize}: #{ability.name.demodulize}" }
    end

    expect(missing).to be_empty
  end

  it "reads as the card prints it, for Elspeth, Sun's Champion" do
    elspeth = ResolvePermanent("Elspeth, Sun's Champion", owner: p1)

    expect(elspeth.loyalty_abilities.map(&:description)).to eq(
      ["Create three 1/1 white Soldier creature tokens.",
       "Destroy all creatures with power 4 or greater.",
       "You get an emblem with \"Creatures you control get +2/+2 and have flying.\""]
    )
  end
end
