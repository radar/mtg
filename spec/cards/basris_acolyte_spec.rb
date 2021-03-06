require 'spec_helper'

RSpec.describe Magic::Cards::BasrisAcolyte do
  include_context "two player game"

  subject { Card("Basri's Acolyte", controller: p1) }

  it "has lifelink" do
    expect(subject.lifelink?).to eq(true)
  end

  context "when there are other creatures on the battlefield" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", controller: p1) }
    let(:wood_elves) { Card("Wood Elves", controller: p1) }
    before do
      game.battlefield.add(loxodon_wayfarer)
      game.battlefield.add(wood_elves)
    end

    it "can add two +1/+1 counters to other creatures" do
      subject.entered_the_battlefield!
      add_counter = game.next_effect
      expect(add_counter).to be_a(Magic::Effects::SingleTargetAndResolve)
      expect(add_counter.choices).to include(loxodon_wayfarer)
      expect(add_counter.choices).to include(wood_elves)
      game.resolve_pending_effect(loxodon_wayfarer)
      expect(loxodon_wayfarer.power).to eq(2)
      expect(loxodon_wayfarer.toughness).to eq(6)

      # Effect is automatically resolved, as there is only one choice
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
    end
  end
end
