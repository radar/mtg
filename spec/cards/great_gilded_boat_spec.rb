# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GreatGildedBoat do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:boat) { ResolvePermanent("Great Gilded Boat", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def crew(*creatures)
    p1.activate_ability(ability: boat.activated_abilities.first) { |a| a.pay_multi_tap(creatures) }
    game.stack.resolve!
    game.tick!
  end

  def soldiers = p1.creatures.select { _1.name == "Human Soldier" }

  it "is a Vehicle artifact that is not a creature until crewed" do
    expect(boat).to be_artifact
    expect(boat.types).to include("Vehicle")
    expect(boat).not_to be_creature
  end

  describe "Crew 2" do
    it "becomes a 4/4 artifact creature when creatures with total power 2 are tapped" do
      crew(bears)

      expect(bears).to be_tapped
      expect(boat).to be_creature
      expect([boat.power, boat.toughness]).to eq([4, 4])
    end

    it "can't be crewed with too little power" do
      weak = ResolvePermanent("Llanowar Elves", owner: p1)
      expect { crew(weak) }.to raise_error(StandardError)
      expect(boat).not_to be_creature
    end

    it "can be crewed by several creatures" do
      one = ResolvePermanent("Llanowar Elves", owner: p1)
      two = ResolvePermanent("Llanowar Elves", owner: p1)
      crew(one, two)
      expect(boat).to be_creature
    end

    it "stops being a creature at end of turn" do
      crew(bears)
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      expect(boat).not_to be_creature
    end
  end

  describe "Whenever you attack, recruit" do
    def attack_with(creature)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: creature, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.stack.resolve!
      game.tick!
    end

    it "draws a card, then discards a card, making a Human Soldier for a nonland discard" do
      spell = Card("Grizzly Bears", owner: p1)
      p1.hand.add(spell)
      library_before = p1.library.count

      attack_with(bears)

      expect(p1.library.count).to eq(library_before - 1)
      game.resolve_choice!(card: spell)
      expect(soldiers.count).to eq(1)
    end

    it "makes no token when a land is discarded" do
      p1.hand.cards.dup.each(&:discard!)
      attack_with(bears)
      game.resolve_choice!(card: p1.hand.cards.first)
      expect(soldiers).to be_empty
    end

    it "doesn't trigger when an opponent attacks" do
      go_to_main_phase_for!(p2)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      library_before = p1.library.count
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      p2.declare_attacker(attacker: theirs, target: p1)
      current_turn.attackers_declared!
      game.settle!
      expect(p1.library.count).to eq(library_before)
    end
  end
end
