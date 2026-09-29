# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbigaleEloquentFirstYear do
  include_context "two player game"

  it "is a 1/1 legendary Bird Bard with flying, first strike and lifelink" do
    abigale = ResolvePermanent("Abigale, Eloquent First-Year", owner: p1)

    expect([abigale.power, abigale.toughness]).to eq([1, 1])
    expect(abigale).to be_legendary
    expect([abigale.flying?, abigale.first_strike?, abigale.lifelink?]).to eq([true, true, true])
  end

  it "can be paid for with white or black hybrid mana" do
    go_to_main_phase!
    card = Card("Abigale, Eloquent First-Year", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 1, black: 1)
    p1.cast(card:) { _1.pay_mana(white: 1, black: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Abigale, Eloquent First-Year")
  end

  context "when it enters" do
    let!(:target) { ResolvePermanent("Shinestriker", owner: p2) } # flying 3/3

    def enter_and_choose(creature)
      ResolvePermanent("Abigale, Eloquent First-Year", owner: p1)
      game.resolve_choice!(target: creature)
      game.tick!
    end

    it "makes up to one other creature lose all abilities, then gives it flying, first strike and lifelink counters" do
      enter_and_choose(target)

      expect(target.counters.map(&:class)).to contain_exactly(
        Magic::Counters::Flying, Magic::Counters::FirstStrike, Magic::Counters::Lifelink
      )
      expect([target.flying?, target.first_strike?, target.lifelink?]).to eq([true, true, true])
    end

    it "removes the creature's own abilities but keeps its counters' keywords" do
      trample = ResolvePermanent("Bristlebane Battler", owner: p2) # trample
      enter_and_choose(trample)

      expect(trample).not_to be_trample
      expect(trample).to be_flying
    end

    it "may target nothing" do
      ResolvePermanent("Abigale, Eloquent First-Year", owner: p1)
      game.skip_choice!

      expect(target.counters.of_type(Magic::Counters::Flying)).to be_empty
      expect(target.lost_all_abilities?).to be(false)
    end

    it "can't target itself" do
      abigale = ResolvePermanent("Abigale, Eloquent First-Year", owner: p1)

      expect(game.choices.last.choices).not_to include(abigale)
    end

    it "does nothing with no other creature" do
      target.destroy!
      game.settle!
      ResolvePermanent("Abigale, Eloquent First-Year", owner: p1)

      expect(game.choices).to be_empty
    end
  end
end
