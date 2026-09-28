# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SyggsCommand do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:command) { Card("Syggs Command", owner: p1) }

  def cast_with(*modes)
    p1.hand.add(command)
    p1.add_mana(white: 1, blue: 2)
    p1.cast(card: command) do |action|
      action.pay_mana(white: 1, blue: 1, generic: { blue: 1 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.tick!
  end

  it "copies a Merfolk you control and gives your creatures lifelink" do
    merfolk = ResolvePermanent("Tributary Vaulter", owner: p1)
    cast_with([described_class::CopyMerfolk, merfolk], [described_class::Lifelink, p1])

    expect(p1.creatures.count { _1.name == "Tributary Vaulter" }).to eq(2)
    expect(p1.creatures).to all(satisfy(&:lifelink?))
  end

  it "draws a card and taps and stuns a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    hand = p1.hand.cards.count
    cast_with([described_class::Draw, p1], [described_class::TapAndStun, bears])

    expect(p1.hand.cards.count).to eq(hand + 1) # +1 draw (the command itself was added then cast)
    expect(bears).to be_tapped
    expect(bears.counters.of_type(Magic::Counters::Stun).count).to eq(1)
  end
end
