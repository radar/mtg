# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GatheringStone do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:elf) { Card("Llanowar Elves", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  def resolve_stone(type: "Elf")
    stone = ResolvePermanent("Gathering Stone", owner: p1)
    game.resolve_choice!(creature_type: type)
    stone
  end

  it "looks at the top card once the type is chosen, offering to take a card of that type" do
    p1.library.add(elf)
    resolve_stone

    choice = game.choices.last
    expect(choice).to be_a(described_class::TopCardChoice)
    game.resolve_choice!(destination: :hand)

    expect(elf.zone).to eq(p1.hand)
  end

  it "may put the top card into the graveyard instead" do
    p1.library.add(elf)
    resolve_stone
    game.resolve_choice!(destination: :graveyard)

    expect(elf.zone).to eq(p1.graveyard)
  end

  it "may leave the top card where it is" do
    p1.library.add(elf)
    resolve_stone
    game.resolve_choice!(destination: :nothing)

    expect(elf.zone).to eq(p1.library)
  end

  it "does not let a card of another type go to your hand" do
    p1.library.add(bears)
    resolve_stone
    expect { game.resolve_choice!(destination: :hand) }.to raise_error(ArgumentError)
  end

  it "looks again at the beginning of your upkeep" do
    resolve_stone
    game.resolve_choice!(destination: :nothing) if game.choices.any?
    game.next_turn
    game.next_turn
    p1.library.add(elf)
    current_turn.untap!
    current_turn.upkeep!

    expect(game.choices.last).to be_a(described_class::TopCardChoice)
  end

  it "makes spells you cast of the chosen type cost {1} less" do
    resolve_stone
    game.resolve_choice!(destination: :nothing) if game.choices.any?
    game.tick!

    cost = Magic::Actions::Cast.new(card: Card("Grizzly Bears", owner: p1), player: p1, game: game).mana_cost
    expect(cost.cost[:generic]).to eq(1)

    p1.hand.add(elf)
    elf_cost = Magic::Actions::Cast.new(card: elf, player: p1, game: game).mana_cost
    expect(elf_cost.cost.values.sum).to eq(1)
    expect(elf_cost.cost[:generic].to_i).to be >= 0
  end

  it "does not reduce spells of another type" do
    resolve_stone(type: "Goblin")
    game.resolve_choice!(destination: :nothing) if game.choices.any?
    game.tick!

    cost = Magic::Actions::Cast.new(card: Card("Grizzly Bears", owner: p1), player: p1, game: game).mana_cost
    expect(cost.cost[:generic]).to eq(1)
  end
end
