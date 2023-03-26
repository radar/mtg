require "spec_helper"

RSpec.describe Magic::Cards::ContainmentPriest do
  include_context "two player game"

  subject! { ResolvePermanent("Containment Priest", owner: p1) }
  # Containment Priest {1}{U}{1}{W}
  # Creature -- Human Cleric
  # Flash (You may cast this spell any time you could cast an instant.)
  # If a nontoken creature would enter the battlefield and it wasn’t cast, exile it instead.

  context "card attributes" do
    it "is a human cleric" do
      expect(subject.card.type_line).to eq("Creature -- Human Cleric")
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
          ResolvePermanent('Story Seeker', owner: p2)
        }.to change { game.exile.cards.count }.by(1)
        expect(game.battlefield.permanents.count).to eq(1)
        expect(game.battlefield.permanents.map(&:name)).to_not include('Story Seeker')
      end
    end

    context "creature goes from graveyard to battlefield" do
      # https://scryfall.com/card/m21/119/rise-again
      pending "P2 casts Rise Again, targeting creature in their GY"
    end

    context "the creature is cast" do
      it "does not exile the creature" do
        story_seeker = Card('Story Seeker')
        p2.hand.add(story_seeker)
        story_seeker.zone = p2.hand

        p2.add_mana(white: 2)
        action = Magic::Actions::Cast.new(player: p2, card: story_seeker)
        action.pay_mana(generic: { white: 1 }, white: 1)
        game.take_action(action)
        game.tick!

        expect(game.battlefield.permanents.count).to eq(2)
        expect(game.battlefield.permanents.map(&:name)).to include('Story Seeker')
      end
    end
  end

  context "when a token creature enters the battlefield" do
    it "does not exile the creature" do
      scute = ResolvePermanent("Scute Swarm", owner: p1, token: true)

      expect(game.battlefield.permanents.count).to eq(2)
    end
  end
end
