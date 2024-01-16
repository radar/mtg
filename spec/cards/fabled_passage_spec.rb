require "spec_helper"

RSpec.describe Magic::Cards::FabledPassage do
  include_context "two player game"

  subject! { ResolvePermanent("Fabled Passage", owner: p1) }

  def p1_library
    9.times.map { Card("Forest") }
  end

  def activate_ability
    p1.activate_ability(ability: subject.activated_abilities.first) do
      _1.pay(:sacrifice)
    end
    game.stack.resolve!
    effect = game.effects.first
    expect(effect).to be_a(Magic::Cards::FabledPassage::Effect)
    game.resolve_pending_effect(effect.choices.first) # A Forest
    expect(subject.zone).to be_nil
    expect(p1.graveyard.by_name(subject.name).count).to eq(1)
  end


  context "when player has 2 lands" do
    before do
      2.times do
        ResolvePermanent("Forest", owner: p1)
      end
    end

    it "finds a land, that land remains tapped" do
      activate_ability

      forest = game.battlefield.cards.by_name("Forest").select(&:tapped?).first
      expect(forest.zone).to be_battlefield
    end
  end

  context "when player has 3 lands" do
    before do
      3.times do
        ResolvePermanent("Forest", owner: p1)
      end
    end

    it "finds a land, that land remains tapped" do
      activate_ability

      forest = game.battlefield.cards.by_name("Forest")
      expect(forest.all?(&:untapped?)).to be_truthy
    end
  end
end
