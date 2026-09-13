require "spec_helper"

RSpec.describe Magic::Cards::CalixDestinysHand do
  include_context "two player game"

  let(:card) { Card("Calix, Destiny's Hand") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with four loyalty" do
    expect(planeswalker.loyalty).to eq(4)
  end

  context "+1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    context "when the top four cards of the library include an enchantment" do
      let!(:glorious_anthem) { add_to_library("Glorious Anthem", player: p1) }

      it "puts the enchantment into hand" do
        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(5)
        expect(p1.hand.cards).to include(glorious_anthem)
        expect(glorious_anthem.zone).to eq(p1.hand)
      end
    end

    context "when the top four cards of the library have no enchantment" do
      it "leaves the library untouched" do
        top_four = p1.library.first(4)

        p1.activate_loyalty_ability(ability: ability)
        game.stack.resolve!
        game.tick!

        expect(planeswalker.loyalty).to eq(5)
        expect(p1.library.first(4)).to eq(top_four)
      end
    end
  end

  context "-3 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "exiles the target creature" do
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(wood_elves)
      end
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(1)
      expect(wood_elves.card.zone).to be_exile
    end

    context "when targeting an enchantment" do
      let!(:glorious_anthem) { ResolvePermanent("Glorious Anthem", owner: p2) }

      it "exiles the target enchantment" do
        p1.activate_loyalty_ability(ability: ability) do
          _1.targeting(glorious_anthem)
        end
        game.stack.resolve!
        game.tick!

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
