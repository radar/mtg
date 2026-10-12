# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EaglesRescue do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:elf) { ResolvePermanent("Elvish Mystic", owner: p1) }
  let(:card) { Card("Eagle's Rescue", owner: p1) }

  def cast_on(creature)
    p1.hand.add(card)
    p1.add_mana(white: 4)
    p1.cast(card: card) do |action|
      action.targeting(creature)
      action.pay_mana(generic: { white: 2 }, white: 2)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives enchanted creature +2/+2 and flying" do
    cast_on(bears)
    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
  end

  context "in the graveyard" do
    before do
      cast_on(bears)
      bears.destroy!
      game.settle!
      game.tick!
      game.stack.resolve!
    end

    def activate(target)
      p1.add_mana(white: 4)
      p1.activate_ability(ability: card.graveyard_abilities.first) do |a|
        a.targeting(target)
        a.pay_mana(generic: { white: 2 }, white: 2)
      end
      game.stack.resolve!
      game.tick!
    end

    it "returns attached to a creature you control with power 1 or less" do
      expect(card.zone).to be_graveyard
      activate(elf)
      expect(elf.attachments.map(&:name)).to eq(["Eagle's Rescue"])
      expect([elf.power, elf.toughness]).to eq([3, 3])
    end

    it "can't target a creature with power greater than 1" do
      expect { activate(ResolvePermanent("Grizzly Bears", owner: p1)) }.to raise_error(StandardError)
    end
  end
end
