# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeornsHospitality do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:hospitality) { ResolvePermanent("Beorns Hospitality", owner: p1) }

  def play_land
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.settle!
  end

  def animate
    p1.activate_ability(ability: hospitality.activated_abilities.first) do |a|
      a.pay_mana(generic: { green: 5 }, green: 2)
    end
    game.stack.resolve!
    game.tick!
  end

  context "landfall" do
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "puts a +1/+1 counter on target creature you control" do
      play_land
      game.resolve_choice!(target: bear)
      expect(bear.power).to eq(3)
      expect(other.power).to eq(2)
    end

    it "does not trigger for an opponent's land" do
      go_to_main_phase_for!(p2)
      forest = Card("Forest", owner: p2)
      p2.hand.add(forest)
      p2.play_land(land: forest)
      game.settle!
      expect(game.choices).to be_empty
    end
  end

  it "is not a creature by default" do
    expect(hospitality.creature?).to eq(false)
  end

  context "{5}{G}{G}" do
    before do
      7.times { ResolvePermanent("Forest", owner: p1) }
      p1.add_mana(green: 7)
    end

    it "becomes a Bear creature with P/T equal to the number of lands you control" do
      animate
      expect(hospitality.creature?).to eq(true)
      expect(hospitality.type?("Bear")).to eq(true)
      expect(hospitality.type?("Enchantment")).to eq(true)
      expect(hospitality.power).to eq(7)
      expect(hospitality.toughness).to eq(7)
    end

    it "tracks the land count" do
      animate
      ResolvePermanent("Forest", owner: p1)
      game.tick!
      # 8 lands, plus the +1/+1 counter its own landfall put on itself (the only creature you control).
      expect(hospitality.power).to eq(9)
    end

    it "lasts past the end of turn" do
      animate
      2.times { game.next_turn }
      go_to_main_phase!
      expect(hospitality.creature?).to eq(true)
    end
  end
end
