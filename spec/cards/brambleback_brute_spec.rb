# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BramblebackBrute do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:brute) { ResolvePermanent("Brambleback Brute", owner: p1) }

  it "is a 4/5 giant warrior that enters with two -1/-1 counters" do
    expect(brute.card.types).to include("Giant", "Warrior")
    expect(brute.power).to eq(2)
    expect(brute.toughness).to eq(3)
  end

  it "stops target creature from blocking this turn, for {1}{R}, remove a counter, as a sorcery" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 2)

    p1.activate_ability(ability: brute.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.can_block?(brute)).to be(false)
  end
end
