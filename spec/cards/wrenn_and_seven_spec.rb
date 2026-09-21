require "spec_helper"

RSpec.describe Magic::Cards::WrennAndSeven do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Wrenn And Seven") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with five loyalty" do
    expect(planeswalker.loyalty).to eq(5)
  end

  context "+1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }
    let!(:wood_elves) { add_to_library("Wood Elves", player: p1) }

    it "puts revealed land cards into hand and the rest into the graveyard" do
      top_four = p1.library.first(4)

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(6)
      expect(p1.hand).to include(*top_four.select(&:land?))
      expect(p1.graveyard).to include(wood_elves)
      expect(p1.hand).not_to include(wood_elves)
    end
  end

  context "0 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }

    it "puts the chosen land cards from hand onto the battlefield tapped" do
      lands = p1.hand.lands.first(2)

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!

      game.resolve_choice!(choices: lands)

      expect(planeswalker.loyalty).to eq(5)
      lands.each do |land|
        expect(land.zone).to be_battlefield
        expect(game.battlefield.by_card(land).first).to be_tapped
      end
    end

    it "may choose to put no lands onto the battlefield" do
      hand_lands_before = p1.hand.lands.count

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!

      game.resolve_choice!(choices: [])

      expect(p1.hand.lands.count).to eq(hand_lands_before)
    end
  end

  context "-3 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }
    let!(:forest1) { ResolvePermanent("Forest", owner: p1) }
    let!(:forest2) { ResolvePermanent("Forest", owner: p1) }

    it "creates a green Treefolk token with reach, power/toughness equal to lands controlled" do
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(2)

      token = creatures.by_name("Treefolk").first
      expect(token).to be_a_token
      expect(token.controller).to eq(p1)
      expect(token.colors).to eq([:green])
      expect(token).to have_keyword(:reach)
      expect(token.power).to eq(p1.lands.count)
      expect(token.toughness).to eq(p1.lands.count)

      ResolvePermanent("Forest", owner: p1)
      game.tick!

      expect(token.power).to eq(p1.lands.count)
      expect(token.toughness).to eq(p1.lands.count)
    end
  end

  context "-8 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[3] }
    let(:sol_ring) { Card("Sol Ring", owner: p1) }
    let(:wood_elves) { Card("Wood Elves", owner: p1) }

    before do
      p1.graveyard.add(sol_ring)
      p1.graveyard.add(wood_elves)
    end

    it "returns permanent cards from the graveyard to hand and grants an emblem" do

      planeswalker.change_loyalty!(3)
      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!

      expect(planeswalker.loyalty).to eq(0)
      expect(p1.hand).to include(sol_ring, wood_elves)
      expect(p1.graveyard).to be_empty
      expect(game.emblems.count).to eq(1)
    end
  end
end
