require 'spec_helper'

RSpec.describe Magic::Cards::BasrisAcolyte do
  include_context "two player game"

  subject { Card("Basri's Acolyte") }

  before do
    p1.hand.add(subject)
  end

  it "has lifelink" do
    expect(subject.lifelink?).to eq(true)
  end

  context "when there are other creatures on the battlefield" do
    let!(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "can add two +1/+1 counters to other creatures" do
      cast_and_resolve(card: subject, player: p1)
      add_counter = game.choices.last
      expect(add_counter).to be_a(Magic::Cards::BasrisAcolyte::FirstChoice)
      expect(add_counter.choices).to include(loxodon_wayfarer)
      expect(add_counter.choices).to include(wood_elves)
      game.resolve_choice!(target: loxodon_wayfarer)
      game.tick!
      expect(loxodon_wayfarer.power).to eq(2)
      expect(loxodon_wayfarer.toughness).to eq(6)

      game.resolve_choice!(target: wood_elves)
      game.tick!

      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
    end
  end
end
