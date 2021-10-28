require 'spec_helper'

RSpec.describe Magic::Cards::Mortify do
  include_context "two player game"

  subject { Card("Mortify", controller: p1) }

  context "destroys a creature" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", controller: p2) }
    before do
      game.battlefield.add(loxodon_wayfarer)
    end

    it "destroys the creature" do
      subject.cast!
      game.stack.resolve!
      expect(loxodon_wayfarer.zone).to be_graveyard
    end
  end

  context "destroys an enchantment" do
    let(:glorious_anthem) { Card("Glorious Anthem", controller: p2) }

    before do
      game.battlefield.add(glorious_anthem)
    end

    it "destroys the enchantment" do
      subject.cast!
      game.stack.resolve!
      expect(glorious_anthem.zone).to be_graveyard
    end
  end
end
