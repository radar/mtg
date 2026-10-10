# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmaugWickedWorm do
  include_context "two player game"
  before { go_to_main_phase! }

  def treasures(player) = player.permanents.select { _1.name == "Treasure" }

  it "is a 5/5 flyer" do
    smaug = ResolvePermanent("Smaug, Wicked Worm", owner: p1)

    expect([smaug.power, smaug.toughness]).to eq([5, 5])
    expect(smaug).to be_flying
  end

  it "creates a tapped Treasure for each artifact your opponents control" do
    ResolvePermanent("Panharmonicon", owner: p2)
    ResolvePermanent("Key To The Side-Door", owner: p2)
    ResolvePermanent("Key To The Side-Door", owner: p1)
    ResolvePermanent("Smaug, Wicked Worm", owner: p1)
    game.settle!

    expect(treasures(p1).count).to eq(2)
    expect(treasures(p1)).to all(be_tapped)
  end

  describe "whenever you cast a spell, if mana from a Treasure was spent" do
    let!(:smaug) { ResolvePermanent("Smaug, Wicked Worm", owner: p1) }
    let!(:treasure) { Magic::Tokens::Treasure.new(game: game, owner: p1).resolve! }

    it "draws a card and loses 1 life" do
      treasure_mana = treasure.activated_abilities.first
      p1.activate_ability(ability: treasure_mana) { _1.choose(:green) }
      p1.add_mana(green: 1)
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)

      expect do
        p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
        game.settle!
        game.stack.resolve!
      end.to change { p1.hand.count }.by(0).and change { p1.life }.by(-1)
    end

    it "does nothing when no Treasure mana was spent" do
      p1.add_mana(green: 2)
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)

      expect do
        p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
        game.settle!
      end.not_to change { p1.life }
    end
  end
end
