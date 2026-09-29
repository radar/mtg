# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeandersGuide do
  include_context "two player game"

  let!(:guide) { ResolvePermanent("Meanders Guide", owner: p1) }
  let!(:shorethief) { ResolvePermanent("Triton Shorethief", owner: p1) }

  def attack_with_guide
    skip_to_combat!
    yield if block_given?
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: guide, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/2 Merfolk Scout" do
    expect([guide.power, guide.toughness]).to eq([3, 2])
    expect(guide.type?("Merfolk")).to eq(true)
  end

  context "when attacking with a card in the graveyard" do
    let!(:bears) { Card("Grizzly Bears", owner: p1) } # mana value 2
    let!(:angel) { Card("Baneslayer Angel", owner: p1) } # mana value 5

    before do
      p1.graveyard.add(bears)
      p1.graveyard.add(angel)
    end

    it "may tap another untapped Merfolk; when you do, returns a creature card with mana value 3 or less" do
      elves = Card("Llanowar Elves", owner: p1)
      p1.graveyard.add(elves)
      attack_with_guide
      expect(game.choices.last.choices).to contain_exactly(shorethief)
      game.resolve_choice!(target: shorethief)
      expect(shorethief).to be_tapped

      expect(game.choices.last.choices.to_a).to contain_exactly(bears, elves)
      game.resolve_choice!(target: bears)
      expect(bears.zone).to be_battlefield
      expect(elves.zone).to be_graveyard
      expect(angel.zone).to be_graveyard
    end

    it "returns the only eligible card without asking" do
      attack_with_guide
      game.resolve_choice!(target: shorethief)
      expect(bears.zone).to be_battlefield
      expect(angel.zone).to be_graveyard
    end

    it "returns nothing if you decline to tap a Merfolk" do
      attack_with_guide
      game.skip_choice!
      expect(shorethief).to be_untapped
      expect(bears.zone).to be_graveyard
      expect(game.choices).to be_empty
    end

    it "offers nothing without another untapped Merfolk" do
      attack_with_guide { shorethief.tap! }
      expect(game.choices).to be_empty
    end
  end

  it "doesn't ask for a return when no card is eligible" do
    p1.graveyard.add(Card("Baneslayer Angel", owner: p1))
    attack_with_guide
    game.resolve_choice!(target: shorethief)
    expect(shorethief).to be_tapped
    expect(game.choices).to be_empty
  end
end
