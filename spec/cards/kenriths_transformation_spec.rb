require "spec_helper"

RSpec.describe Magic::Cards::KenrithsTransformation do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Kenrith's Transformation", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p2) }

  def enchant(target)
    p1.add_mana(green: 2)
    p1.cast(card: card) do
      _1.pay_mana(generic: { green: 1 }, green: 1)
      _1.targeting(target)
    end
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "can target any creature, including an opponent's" do
    expect(card.target_choices).to include(angel)
  end

  it "draws a card when it enters" do
    expect { enchant(angel) }.to change { p1.hand.count }.by(1)
  end

  context "once attached" do
    before { enchant(angel) }

    it "makes the creature a 3/3" do
      expect(angel.power).to eq(3)
      expect(angel.toughness).to eq(3)
    end

    it "makes it a green Elk creature, losing its other types" do
      expect(angel.types).to eq([Magic::Types::Creature, Magic::Types::Creatures["Elk"]])
      expect(angel.colors).to eq([:green])
      expect(angel).to be_creature
    end

    it "loses all abilities" do
      expect(angel).not_to be_flying
      expect(angel).not_to be_lifelink
      expect(angel).not_to be_first_strike
    end

    it "returns to normal when the Aura leaves the battlefield" do
      kenriths = game.battlefield.by_name("Kenrith's Transformation").first
      kenriths.destroy!
      game.tick!

      expect(angel.power).to eq(5)
      expect(angel).to be_flying
      expect(angel.colors).to eq([:white])
    end
  end

  it "removes activated abilities" do
    fanatic = ResolvePermanent("Mogg Fanatic", owner: p2)
    expect(fanatic.activated_abilities).not_to be_empty

    enchant(fanatic)
    expect(fanatic.activated_abilities).to be_empty
  end
end
