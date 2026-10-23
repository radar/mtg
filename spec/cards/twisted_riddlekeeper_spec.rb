# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwistedRiddlekeeper do
  include_context "two player game"

  let(:card) { Card("Twisted Riddlekeeper", owner: p1) }

  before { go_to_main_phase! }

  it "is a 5/5 flyer" do
    riddlekeeper = ResolvePermanent("Twisted Riddlekeeper", owner: p1)

    expect([riddlekeeper.power, riddlekeeper.toughness]).to eq([5, 5])
    expect(riddlekeeper.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
  end

  it "can be hard-cast for {8}" do
    p1.hand.add(card)
    p1.add_mana(green: 8)
    p1.cast(card:) { _1.pay_mana(generic: { green: 8 }) }
    game.stack.resolve!
    game.skip_choice!
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Twisted Riddlekeeper")
  end

  describe "emerge" do
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
    let!(:target_one) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:target_two) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      p1.hand.add(card)
      p1.add_mana(blue: 1, colorless: 1)
    end

    it "sacrifices a creature to reduce the cost by its mana value" do
      p1.cast_as(:alternative, card:) do |action|
        action.emerge(dreadmaw)
        action.pay_mana(colorless: 1, blue: 1)
      end

      expect(p1.creatures.map(&:name)).not_to include("Colossal Dreadmaw")
      expect(p1.graveyard.cards.map(&:name)).to include("Colossal Dreadmaw")
    end

    it "taps up to two target permanents and stuns them when cast" do
      p1.cast_as(:alternative, card:) do |action|
        action.emerge(dreadmaw)
        action.pay_mana(colorless: 1, blue: 1)
      end
      game.stack.resolve!
      game.resolve_choice!(targets: [target_one, target_two])
      game.settle!
      game.stack.resolve!

      expect([target_one.tapped?, target_two.tapped?]).to eq([true, true])
      expect(target_one.counters.of_type(Magic::Counters::Stun).count).to eq(1)
      expect(p1.creatures.map(&:name)).to include("Twisted Riddlekeeper")
    end

    it "refuses a creature the opponent controls" do
      expect {
        p1.cast_as(:alternative, card:) { _1.emerge(target_one) }
      }.to raise_error(/does not control/)
    end
  end
end
