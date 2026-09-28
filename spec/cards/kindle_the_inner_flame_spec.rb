# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KindleTheInnerFlame do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:kindle) { Card("Kindle The Inner Flame", owner: p1) }
  let!(:target) { ResolvePermanent("Shinestriker", owner: p1) }

  it "creates a hasty token copy that is sacrificed at the end step" do
    p1.hand.add(kindle)
    p1.add_mana(red: 4)
    p1.cast(card: kindle) do |action|
      action.pay_mana(red: 1, generic: { red: 3 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.tick!

    copy = p1.creatures.find { _1.token? }
    expect(copy.name).to eq("Shinestriker")
    expect(copy.haste?).to eq(true)
    expect(copy.summoning_sick?).to eq(false)

    current_turn.end!
    game.settle!
    expect(p1.creatures.select(&:token?)).to be_empty
    expect(p1.creatures).to include(target)
  end

  context "flashback" do
    before { kindle.move_to_graveyard!(p1) }

    it "costs {1}{R}" do
      action = cast_action(player: p1, card: kindle, flashback: true)
      expect(action.mana_cost).to eq(Magic::Costs::Mana.new(generic: 1, red: 1))
    end

    it "is illegal without three Elementals to behold" do
      action = cast_action(player: p1, card: kindle, flashback: true)
      expect(action.illegal_reason).to match(/flashback requirements/)
    end

    it "is legal when you control three Elementals" do
      2.times { ResolvePermanent("Shinestriker", owner: p1) }
      action = cast_action(player: p1, card: kindle, flashback: true)
      expect(action.illegal_reason).to be_nil
    end

    it "counts Elemental cards in hand, and exiles the card after resolving" do
      p1.hand.add(Card("Shinestriker", owner: p1))
      p1.hand.add(Card("Shinestriker", owner: p1))
      p1.add_mana(red: 2)
      p1.cast(card: kindle, flashback: true) do |action|
        action.pay_mana(red: 1, generic: { red: 1 })
        action.targeting(target)
      end
      game.stack.resolve!

      expect(kindle.zone).to be_exile
    end
  end
end
