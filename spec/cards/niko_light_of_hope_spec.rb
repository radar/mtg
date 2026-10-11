# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NikoLightOfHope do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:niko) { ResolvePermanent("Niko Light Of Hope", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p1) }

  def shard_tokens = p1.permanents.select { _1.type?("Shard") }

  def activate!(target)
    p1.add_mana(white: 2)
    p1.activate_ability(ability: niko.activated_abilities.first) do |action|
      action.pay_mana(generic: { white: 2 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 3/4 Human Wizard that creates two Shard tokens when it enters" do
    expect([niko.power, niko.toughness]).to eq([3, 4])
    expect(shard_tokens.size).to eq(2)
    expect(shard_tokens.first).to be_enchantment
  end

  describe "a Shard" do
    it "scries 1 then draws a card for {2} and a sacrifice" do
      shard = shard_tokens.first
      hand_size = p1.hand.cards.count
      p1.add_mana(blue: 2)
      p1.activate_ability(ability: shard.activated_abilities.first) { _1.pay_mana(generic: { blue: 2 }) }
      game.stack.resolve!
      game.settle!
      expect(p1.hand.cards.count).to eq(hand_size) # still scrying
      game.resolve_choice!(top: p1.library.first(1), bottom: [])

      expect(p1.hand.cards.count).to eq(hand_size + 1)
      expect(shard.zone).to be_nil
    end
  end

  describe "the exile ability" do
    it "exiles target nonlegendary creature you control" do
      activate!(angel)

      expect(angel.zone).to be_nil
      expect(angel.card.zone).to be_exile
    end

    it "can't target a legendary creature" do
      expect(niko.activated_abilities.first.target_choices).to contain_exactly(angel)
    end

    it "makes Shards you control copies of it until the next end step" do
      activate!(angel)

      expect(shard_tokens).to be_empty
      copies = p1.permanents.select { _1.token? && _1.name == "Baneslayer Angel" }
      expect(copies.size).to eq(2)
      expect(copies.first).to have_keyword(:flying)
    end

    it "returns it, and the Shards revert, at the beginning of the next end step" do
      activate!(angel)
      current_turn.end!
      game.settle!

      returned = p1.permanents.find { _1.card == angel.card }
      expect(returned).not_to be_nil
      expect(shard_tokens.size).to eq(2)
      expect(shard_tokens.first).not_to have_keyword(:flying)
    end

    it "returns it under its owner's control" do
      activate!(angel)
      current_turn.end!
      game.settle!

      expect(p1.permanents.find { _1.card == angel.card }.controller).to eq(p1)
    end
  end
end
