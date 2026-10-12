# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnchantedRiversGrasp do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:victim) { ResolvePermanent("Serra Angel", owner: p2) }
  let(:card) { Card("Enchanted River's Grasp", owner: p1) }

  before do
    victim.add_counter("+1/+1")
    victim.add_counter("+1/+1")
    p1.hand.add(card)
    p1.add_mana(blue: 3)
    p1.cast(card: card) do |action|
      action.targeting(victim)
      action.pay_mana(generic: { blue: 2 }, blue: 1)
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "taps the enchanted creature and removes all counters from it" do
    expect(victim).to be_tapped
    expect(victim.counters.count).to eq(0)
  end

  it "makes it lose all abilities" do
    expect(victim.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(false)
    expect(victim.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(false)
  end

  it "stops it untapping during its controller's untap step" do
    game.next_turn
    game.next_turn
    go_to_main_phase!
    expect(victim).to be_tapped
  end
end
