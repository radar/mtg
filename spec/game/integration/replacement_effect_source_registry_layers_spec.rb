require 'spec_helper'

RSpec.describe Magic::Game, 'replacement effects -- source registry layers' do
  include_context 'two player game'

  class RuleCounterReplacement
    class AddOneCounter < Magic::ReplacementEffect
      def applies?(effect)
        effect.is_a?(Magic::Effects::AddCounterToPermanent)
      end

      def call(effect)
        Magic::Effects::AddCounterToPermanent.new(
          source: effect.source,
          counter_type: effect.counter_type,
          target: effect.target,
          amount: effect.amount + 1,
        )
      end
    end

    def replacement_effect_for(context)
      replacement = AddOneCounter.new(receiver: self)
      replacement if replacement.applies_with_context?(context)
    end

    def to_s
      '#<RuleCounterReplacement>'
    end
  end

  let!(:wood_elves) { ResolvePermanent('Wood Elves', owner: p1) }

  let(:counter_effect) do
    Magic::Effects::AddCounterToPermanent.new(
      source: wood_elves,
      counter_type: Magic::Counters::Plus1Plus1,
      target: wood_elves,
      amount: 1,
    )
  end

  it 'includes registered rule-level replacement sources' do
    game.add_rule_effect_source(RuleCounterReplacement.new)

    game.add_effect(counter_effect)

    expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
  end

  it 'excludes lost players from replacement source scanning' do
    p2.lose!

    expect(game.replacement_effect_sources).not_to include(p2)
  end
end
