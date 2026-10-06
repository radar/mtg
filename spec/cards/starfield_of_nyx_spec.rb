require "spec_helper"

RSpec.describe Magic::Cards::StarfieldOfNyx do
  include_context "two player game"

  it "gives an enchantment token (mana value 0) 0/0 without failing" do
    token = Magic::Cards::HeliodGodOfTheSun::ClericToken.new(game: game, owner: p1).resolve!
    ResolvePermanent("Starfield of Nyx", owner: p1)

    expect { game.tick! }.not_to raise_error
    expect(token.mana_value).to eq(0)
  end

  let!(:starfield) { ResolvePermanent("Starfield of Nyx", owner: p1) }

  it "is an enchantment" do
    expect(starfield).to be_enchantment
  end

  context "with fewer than five enchantments" do
    it "leaves other enchantments alone" do
      sanctum = ResolvePermanent("Phyrexian Arena", owner: p1)
      game.tick!

      expect(sanctum).not_to be_creature
    end
  end

  context "with five or more enchantments" do
    let!(:arena) { ResolvePermanent("Phyrexian Arena", owner: p1) }
    let!(:procession) { ResolvePermanent("Anointed Procession", owner: p1) }
    let!(:presence) { ResolvePermanent("Enchantress's Presence", owner: p1) }
    let!(:font) { ResolvePermanent("Font Of Fertility", owner: p1) }

    before { game.tick! }

    it "makes each other enchantment a creature with base power and toughness equal to its own mana value" do
      expect(arena).to be_creature
      expect([arena.power, arena.toughness]).to eq([3, 3])
      expect([procession.power, procession.toughness]).to eq([4, 4])
      expect([presence.power, presence.toughness]).to eq([3, 3])
      expect([font.power, font.toughness]).to eq([1, 1])
    end

    it "does not animate itself" do
      expect(starfield).not_to be_creature
    end
  end

  describe "the upkeep trigger" do
    it "lets you return a non-Aura enchantment card from your graveyard to the battlefield" do
      arena_card = Card("Phyrexian Arena", owner: p1)
      p1.graveyard.add(arena_card)

      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::StarfieldOfNyx::UpkeepChoice)
      expect(choice.choices).to eq([arena_card])
      game.resolve_choice!(target: arena_card)

      expect(game.battlefield.permanents.map(&:name)).to include("Phyrexian Arena")
    end
  end
end
