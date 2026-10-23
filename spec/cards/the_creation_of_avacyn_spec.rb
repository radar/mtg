# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheCreationOfAvacyn do
  include_context "two player game"

  let(:card) { Card("The Creation Of Avacyn", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }
  let!(:forest) { Card("Forest", owner: p1).tap { p1.library.add(_1) } }

  def saga = game.battlefield.by_name("The Creation of Avacyn").first

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 3)
    p1.cast(card: card) { _1.pay_mana(black: 2, generic: { black: 1 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def exile_a(chosen)
    game.resolve_choice!(targets: [chosen])
  end

  context "chapter I" do
    it "exiles a card of your choice from your library" do
      exile_a(bears)

      expect(game.exile.cards).to include(bears)
      expect(p1.library.cards).not_to include(bears)
    end
  end

  context "a creature card was exiled" do
    before { exile_a(bears) }

    it "II — loses life equal to its mana value" do
      expect { next_chapter }.to change { p1.life }.by(-bears.mana_value)
    end

    it "III — may put it onto the battlefield" do
      next_chapter
      next_chapter
      game.resolve_choice!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "III — puts it into hand if declined" do
      next_chapter
      next_chapter
      game.skip_choice!

      expect(p1.hand.cards).to include(bears)
    end
  end

  context "a noncreature card was exiled" do
    before { exile_a(forest) }

    it "II — loses no life" do
      expect { next_chapter }.not_to(change { p1.life })
    end

    it "III — puts it into hand" do
      next_chapter
      next_chapter

      expect(p1.hand.cards).to include(forest)
    end
  end
end
