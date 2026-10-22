# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NaduWingedWisdom do
  include_context "two player game"

  let!(:nadu) { ResolvePermanent("Nadu, Winged Wisdom", owner: p1) }

  # Titanic Growth keeps repeated targets alive; the caster may be either player.
  def target_with_bolt(creature, player: p1)
    player.add_mana(green: 2)
    player.cast(card: Card("Titanic Growth", owner: player)) do
      _1.auto_pay_mana
      _1.targeting(creature)
    end
    game.settle!
  end

  def resolve_all
    game.stack.resolve! until game.stack.empty?
    game.settle!
  end

  def put_on_top(name)
    Card(name, owner: p1).tap { p1.library.add(_1) }
  end

  it "is a 3/4 legendary Bird Wizard with flying" do
    expect(nadu.power).to eq(3)
    expect(nadu.toughness).to eq(4)
    expect(nadu.keywords).to include(Magic::Cards::Keywords::FLYING)
    expect(nadu.card.type?("Legendary")).to be(true)
    expect(nadu.card.type?("Bird")).to be(true)
  end

  it "puts a revealed land onto the battlefield when it becomes the target of a spell" do
    forest = put_on_top("Forest")
    target_with_bolt(nadu)
    resolve_all

    expect(p1.permanents.map(&:card)).to include(forest)
    expect(p1.hand.cards).not_to include(forest)
  end

  it "puts a revealed nonland card into your hand" do
    bears = put_on_top("Grizzly Bears")
    target_with_bolt(nadu)
    resolve_all

    expect(p1.hand.cards).to include(bears)
  end

  it "gives other creatures you control the ability" do
    other = ResolvePermanent("Serra Angel", owner: p1)
    bears = put_on_top("Grizzly Bears")
    target_with_bolt(other)
    resolve_all

    expect(p1.hand.cards).to include(bears)
  end

  it "triggers on abilities as well as spells" do
    forest = put_on_top("Forest")
    ability_source = ResolvePermanent("Serra Angel", owner: p2)
    # The engine announces BecameTarget for activated and triggered abilities exactly as for spells.
    game.notify!(Magic::Events::BecameTarget.new(permanent: nadu, controller: p2, source: ability_source))
    game.settle!
    resolve_all

    expect(p1.permanents.map(&:card)).to include(forest)
  end

  it "does not give the ability to creatures an opponent controls" do
    theirs = ResolvePermanent("Serra Angel", owner: p2)
    bears = put_on_top("Grizzly Bears")
    target_with_bolt(theirs, player: p1)
    resolve_all

    expect(p2.hand.cards).not_to include(bears)
    expect(p1.hand.cards).not_to include(bears)
  end

  it "triggers only twice each turn for a given creature" do
    cards = %w[Forest Island Plains].map { put_on_top(_1) }.reverse
    3.times do
      target_with_bolt(nadu)
      resolve_all
    end
    nadu.heal! if nadu.respond_to?(:heal!)

    revealed = cards.count { |c| c.zone.nil? || c.zone.battlefield? }
    expect(revealed).to eq(2)
    expect(p1.library.cards).to include(cards.last)
  end

  it "tracks the limit per creature" do
    other = ResolvePermanent("Serra Angel", owner: p1)
    2.times { put_on_top("Forest") }
    2.times do
      target_with_bolt(other)
      resolve_all
    end
    put_on_top("Forest")
    forests_before = p1.permanents.count { _1.name == "Forest" }
    target_with_bolt(nadu)
    resolve_all

    expect(p1.permanents.count { _1.name == "Forest" }).to eq(forests_before + 1)
  end

  it "resets the limit on a new turn" do
    2.times do
      put_on_top("Forest")
      target_with_bolt(nadu)
      resolve_all
    end
    current_turn.end!
    current_turn.cleanup!
    game.next_turn
    game.next_turn
    go_to_main_phase!
    bears = put_on_top("Grizzly Bears")
    target_with_bolt(nadu)
    resolve_all

    expect(p1.hand.cards).to include(bears)
  end

  it "stops granting the ability when Nadu leaves the battlefield" do
    other = ResolvePermanent("Serra Angel", owner: p1)
    bears = put_on_top("Grizzly Bears")
    nadu.destroy!
    game.settle!
    target_with_bolt(other)
    resolve_all

    expect(p1.hand.cards).not_to include(bears)
  end
end
