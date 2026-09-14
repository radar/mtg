# frozen_string_literal: true

require "spec_helper"

TestGoblinWithAbility = Magic::Cards.Creature("Test Goblin") do
  cost red: 1
  creature_type "Goblin"
  power 1
  toughness 1
end

class TestGoblinWithAbility
  class PingAbility < Magic::ActivatedAbility
    costs "{T}"

    def resolve!
      trigger_effect(:draw_cards, number_to_draw: 1)
    end
  end

  def activated_abilities = [PingAbility]
end

RSpec.describe Magic::Cards::ConspicuousSnoop do
  include_context "two player game"

  subject!(:snoop) { ResolvePermanent("Conspicuous Snoop", owner: p1) }

  it "is a 2/2 Goblin Rogue" do
    expect(snoop.power).to eq(2)
    expect(snoop.toughness).to eq(2)
    expect(snoop.types).to include("Goblin")
  end

  it "reveals the top card of your library when it enters the battlefield" do
    top_card = p1.library.first
    expect(top_card.revealed?).to eq(true)
  end

  it "reveals the new top card of your library after you draw" do
    p1.draw!
    new_top_card = p1.library.first
    expect(new_top_card.revealed?).to eq(true)
  end

  it "lets you cast a Goblin spell from the top of your library" do
    goblin_spell = Card("Raging Goblin", owner: p1)
    p1.library.add(goblin_spell)
    p1.add_mana(red: 1)

    action = player_cast_from_top(goblin_spell)
    expect(action.can_perform?).to eq(true)
  end

  it "doesn't let you cast a non-Goblin spell from the top of your library" do
    non_goblin = Card("Grizzly Bears", owner: p1)
    p1.library.add(non_goblin)

    action = player_cast_from_top(non_goblin)
    expect(action.can_perform?).to eq(false)
  end

  it "has all activated abilities of a Goblin card on top of your library" do
    goblin = TestGoblinWithAbility.new(game: game, owner: p1)
    p1.library.add(goblin)
    game.tick!

    ability = snoop.activated_abilities.find { |a| a.is_a?(TestGoblinWithAbility::PingAbility) }
    expect(ability).not_to be_nil

    starting_hand_size = p1.hand.count
    p1.activate_ability(ability: ability)
    game.stack.resolve!

    expect(p1.hand.count).to eq(starting_hand_size + 1)
    expect(snoop.tapped?).to eq(true)
  end

  it "doesn't have extra activated abilities when the top card isn't a Goblin" do
    non_goblin = Card("Grizzly Bears", owner: p1)
    p1.library.add(non_goblin)
    game.tick!

    expect(snoop.activated_abilities).to be_empty
  end

  def player_cast_from_top(card)
    Magic::Actions::Cast.new(card: card, player: p1, game: game)
  end
end
