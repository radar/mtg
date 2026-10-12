# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DownDownToGoblinTown do
  include_context "two player game"

  def p1_library = 20.times.map { Card("Swamp") }

  let(:card) { Card("Down, Down To Goblin Town", owner: p1) }
  let(:land) { Card("Forest", owner: p2) }
  let(:spell) { Card("Grizzly Bears", owner: p2) }

  before do
    [*p2.hand.cards].each { p2.hand.remove(_1) }
    p2.hand.add(land)
    p2.hand.add(spell)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 3)
    p1.cast(card: card) { _1.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — the opponent reveals their hand and discards a nonland card you choose" do
    choice = game.choices.last
    expect(choice.choices).to eq([spell])
    game.resolve_choice!(card: spell)

    expect(p2.graveyard.cards).to include(spell)
    expect(p2.hand.cards).to include(land)
  end

  context "after chapter I" do
    before { game.resolve_choice!(card: spell) }

    it "II — amasses Goblins 1" do
      next_chapter
      army = p1.creatures.find { _1.type?("Army") }
      expect(army.type?("Goblin")).to eq(true)
      expect([army.power, army.toughness]).to eq([1, 1])
    end

    it "III and IV — drain the opponent for 1 each, then the Saga is sacrificed" do
      next_chapter
      p1_life = p1.life
      p2_life = p2.life
      next_chapter
      expect([p2.life, p1.life]).to eq([p2_life - 1, p1_life + 1])
      next_chapter
      expect([p2.life, p1.life]).to eq([p2_life - 2, p1_life + 2])
      expect(p1.graveyard.by_name("Down, Down to Goblin-town").count).to eq(1)
    end
  end
end
