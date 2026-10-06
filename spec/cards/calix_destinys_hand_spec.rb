require "spec_helper"

RSpec.describe Magic::Cards::CalixDestinysHand do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Calix, Destiny's Hand") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with four loyalty" do
    expect(planeswalker.loyalty).to eq(4)
  end

  context "+1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    context "when the top four cards of the library include an enchantment" do
      let!(:glorious_anthem) { add_to_library("Glorious Anthem", player: p1) }

      it "lets you put the enchantment into hand, and the rest go to the bottom" do
        others = p1.library.first(4) - [glorious_anthem]
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(5)
        game.resolve_choice!(target: glorious_anthem)
        expect(p1.hand.cards).to include(glorious_anthem)
        expect(glorious_anthem.zone).to eq(p1.hand)
        expect(p1.library.last(3)).to match_array(others)
      end

      it "lets you take nothing" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!
        game.resolve_choice!(target: nil)

        expect(p1.hand.cards).not_to include(glorious_anthem)
        expect(p1.library.last(4)).to include(glorious_anthem)
      end
    end

    context "when the top four cards of the library have no enchantment" do
      it "puts all four on the bottom without asking" do
        top_four = p1.library.first(4)

        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(5)
        expect(game.choices).to be_empty
        expect(p1.library.last(4)).to match_array(top_four)
      end
    end
  end

  context "-3 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
    let!(:my_anthem) { ResolvePermanent("Glorious Anthem", owner: p1) }

    def activate(exiled, enchantment)
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(exiled, enchantment)
      end
      game.stack.resolve!
      game.tick!
    end

    it "exiles the target creature" do
      activate(wood_elves, my_anthem)

      expect(planeswalker.loyalty).to eq(1)
      expect(wood_elves.card.zone).to be_exile
    end

    it "returns the exiled card when the enchantment leaves the battlefield" do
      activate(wood_elves, my_anthem)

      my_anthem.destroy!
      game.settle!

      expect(wood_elves.card.zone).to be_battlefield
      expect(game.battlefield.creatures.by_name("Wood Elves").controlled_by(p2).count).to eq(1)
    end

    it "keeps the card exiled while the enchantment stays" do
      activate(wood_elves, my_anthem)
      game.settle!

      expect(wood_elves.card.zone).to be_exile
    end

    it "cannot target an enchantment you do not control as the second target" do
      their_anthem = ResolvePermanent("Glorious Anthem", owner: p2)

      expect { activate(wood_elves, their_anthem) }.to raise_error(/Invalid target/)
    end

    context "when targeting an enchantment to exile" do
      let!(:glorious_anthem) { ResolvePermanent("Glorious Anthem", owner: p2) }

      it "exiles the target enchantment" do
        activate(glorious_anthem, my_anthem)

        expect(glorious_anthem.card.zone).to be_exile
      end
    end
  end

  context "-7 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }
    let(:glorious_anthem) { Card("Glorious Anthem", owner: p1) }

    before do
      p1.graveyard.add(glorious_anthem)

      3.times do
        p1.activate_loyalty_ability(ability: planeswalker.loyalty_abilities.first)
        game.stack.resolve!
        game.tick!
        # A planeswalker can only activate one loyalty ability per turn
        2.times { game.next_turn }
        go_to_main_phase!
      end
    end

    it "returns enchantment cards from the graveyard to the battlefield" do
      expect(planeswalker.loyalty).to eq(7)

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(0)
      expect(game.battlefield.cards.by_name("Glorious Anthem").controlled_by(p1).count).to eq(1)
      expect(p1.graveyard.cards).not_to include(glorious_anthem)
    end
  end
end
