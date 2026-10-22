# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExpelTheUnworthy do
  include_context "two player game"

  let(:card) { Card("Expel The Unworthy", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p2) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def cast(target, kicked: false)
    p1.add_mana(white: kicked ? 5 : 2)
    p1.cast(card: card) do |action|
      action.pay_mana(white: 1, generic: { white: 1 })
      action.pay_kicker(generic: { white: 2 }, white: 1) if kicked
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "only targets creatures with mana value 3 or less when not kicked" do
    expect(card.target_choices.to_a).to contain_exactly(bears)
  end

  it "exiles the creature and its controller gains life equal to its mana value" do
    expect { cast(bears) }.to change { p2.life }.by(2)

    expect(game.exile.cards).to include(bears.card)
    expect(p2.permanents).not_to include(bears)
  end

  it "targets any creature when kicked" do
    p1.add_mana(white: 5)
    p1.cast(card: card) do |action|
      action.pay_mana(white: 1, generic: { white: 1 })
      action.pay_kicker(generic: { white: 2 }, white: 1)
      expect(card.target_choices.to_a).to contain_exactly(bears, angel)
      action.targeting(angel)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(20 + 5)
    expect(p2.permanents).not_to include(angel)
  end
end
