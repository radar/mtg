require 'spec_helper'

RSpec.describe Magic::Cards::Mortify do
  include_context "two player game"

  subject(:card) { Card("Mortify") }

  context "destroys a creature" do
    let(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p1) }
    it "destroys the creature" do
      action = cast_action(card: card, player: p1).targeting(loxodon_wayfarer)
      add_to_stack_and_resolve(action)
      expect(loxodon_wayfarer).to be_dead
    end
  end

  context "destroys an enchantment" do
    let(:glorious_anthem) { ResolvePermanent("Glorious Anthem", owner: p1) }

    it "destroys the enchantment" do
      action = cast_action(card: card, player: p1).targeting(glorious_anthem)
      add_to_stack_and_resolve(action)
      expect(glorious_anthem.zone).to be_nil
    end
  end
end
