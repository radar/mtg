# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnableToScream do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Unable To Scream", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p2) }

  def enchant(target)
    p1.add_mana(blue: 1)
    p1.cast(card: card) do
      _1.pay_mana(blue: 1)
      _1.targeting(target)
    end
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "can target any creature, including an opponent's" do
    expect(card.target_choices).to include(angel)
  end

  context "once attached" do
    before { enchant(angel) }

    it "makes the creature a 0/2" do
      expect([angel.power, angel.toughness]).to eq([0, 2])
    end

    it "makes it a Toy artifact creature in addition to its other types" do
      expect(angel.types).to include(Magic::Types::Artifact, Magic::Types::Creature, Magic::Types::Creatures["Toy"])
      expect(angel.type?("Angel")).to be(true)
    end

    it "loses all abilities" do
      expect(angel).not_to be_flying
      expect(angel).not_to be_lifelink
    end

    it "returns to normal when the Aura leaves the battlefield" do
      game.battlefield.by_name("Unable to Scream").first.destroy!
      game.tick!

      expect(angel.power).to eq(5)
      expect(angel).to be_flying
    end
  end

  context "enchanting a face-down creature" do
    let(:bears) { Card("Grizzly Bears", owner: p2).tap { p2.library.add(_1) } }
    let(:manifested) { game.manifest!(bears, controller: p2) }

    it "can't be turned face up" do
      enchant(manifested)

      expect(manifested.can_be_turned_face_up?).to be(false)
      action = Magic::Actions::TurnFaceUp.new(game: game, player: p2, permanent: manifested)
      expect(action.illegal_reason).to match(/can't be turned face up/)
    end

    it "can be turned face up again once the Aura is gone" do
      enchant(manifested)
      expect(manifested.can_be_turned_face_up?).to be(false)

      game.battlefield.by_name("Unable to Scream").first.destroy!
      game.tick!
      expect(manifested.can_be_turned_face_up?).to be(true)
    end

    it "doesn't stop turning other permanents face up" do
      enchant(angel)

      expect(manifested.can_be_turned_face_up?).to be(true)
    end
  end
end
