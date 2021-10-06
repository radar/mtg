require 'spec_helper'

RSpec.describe Magic::Cards::BasrisAcolyte do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { Card("Basri's Acolyte", controller: p1) }

  it "has lifelink" do
    expect(subject.lifelink?).to eq(true)
  end

  context "when there are other creatures on the battlefield" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", controller: p1) }
    before do
      game.battlefield.add(loxodon_wayfarer)
    end

    it "can add two +1/+1 counters to other creatures" do
      subject.entered_the_battlefield!
      add_counter = game.next_effect
      expect(add_counter).to be_a(Magic::Effects::AddCounter)
      game.resolve_effect(add_counter, targets: [loxodon_wayfarer])
      expect(loxodon_wayfarer.power).to eq(2)
      expect(loxodon_wayfarer.toughness).to eq(6)
    end
  end
end
