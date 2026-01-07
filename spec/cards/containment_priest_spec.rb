require "spec_helper"

RSpec.describe Magic::Cards::ContainmentPriest do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  subject! { ResolvePermanent("Containment Priest", owner: p1) }
  # Containment Priest {1}{U}{1}{W}
  # Creature -- Human Cleric
  # Flash (You may cast this spell any time you could cast an instant.)
  # If a nontoken creature would enter the battlefield and it wasn’t cast, exile it instead.

  context "card attributes" do
    it "is a human cleric" do
      expect(subject.card.types).to include("Creature")
      expect(subject.card.types).to include("Human")
      expect(subject.card.types).to include("Cleric")
    end

    it "has flash" do
      expect(subject.flash?).to eq(true)
    end

    it "has a power + toughness" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end

  context "when a non-token creature enters the battlefield" do
    context "the creature is not cast" do
      it "exiles the creature" do
        expect{
          ResolvePermanent('Story Seeker', owner: p2, cast: false)
        }.to change { game.exile.cards.count }.by(1)

        expect(game.battlefield.permanents.count).to eq(2)
        expect(game.battlefield.permanents.map(&:name)).to_not include('Story Seeker')
      end
    end

    context "the creature is cast" do
      it "does not exile the creature" do
        story_seeker = Card('Story Seeker')
        p2.hand.add(story_seeker)
        story_seeker.zone = p2.hand

        p2.add_mana(white: 2)
        p2.cast(card: story_seeker) do
          _1.pay_mana(generic: { white: 1 }, white: 1)
        end
        game.stack.resolve!

        expect(game.battlefield.permanents.count).to eq(3)
        expect(game.battlefield.permanents.map(&:name)).to include('Story Seeker')
      end
    end

    context "the creature returns from the graveyard via a sorcery" do
      it "exiles the creature" do
        p2.graveyard << Card('Story Seeker')
        p2.add_mana(black: 5)
        rise_again = Card("Rise Again", owner: p2)
        p2.hand.add(rise_again)
        p2.cast(card: rise_again) do
          _1
            .pay_mana(generic: { black: 4 }, black: 1)
            .targeting(p2.graveyard.cards.first)
        end

        p2.add_mana(red: 1)
        shock = Card("Shock", owner: p2)
        p2.hand.add(shock)
        p2.cast(card: shock) do
          _1
            .pay_mana(red: 1)
            .targeting(wood_elves)
        end

        expect{
          game.stack.resolve!
          game.tick!
        }.to change { game.exile.cards.count }.by(1)
        expect(game.battlefield.permanents.count).to eq(1)
        expect(game.battlefield.permanents.map(&:name)).to_not include('Story Seeker')
      end
    end
  end

  context "when a token creature enters the battlefield" do
    it "does not exile the creature" do
      scute = ResolvePermanent("Scute Swarm", owner: p1, token: true)

      expect(game.battlefield.permanents.count).to eq(3)
    end
  end
end
