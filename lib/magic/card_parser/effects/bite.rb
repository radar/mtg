# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target creature you control deals damage equal to its power to target creature or planeswalker."
      # A spell with two targets (`multi_target?`, `resolve!(targets:)`), chosen on casting: the creature
      # you control, then what it damages (`Permanents::Creature#bite!`). One-way, unlike a fight, and the
      # two targets may be the same creature (two instances of "target"). Only instants and sorceries:
      # see EffectList#spell_source.
      class Bite < Data.define(:victims)
        include Effect

        VICTIMS = {
          "creature" => "battlefield.creatures",
          "creature or planeswalker" => "(battlefield.creatures + battlefield.planeswalkers)",
          "creature or planeswalker you don't control" => "(battlefield.not_controlled_by(controller).creatures + battlefield.not_controlled_by(controller).planeswalkers)",
          "creature an opponent controls" => "battlefield.not_controlled_by(controller).creatures"
        }.freeze
        LINE = /\ATarget creature you control deals damage equal to its power to target (?<kind>#{VICTIMS.keys.join('|')})\.?\z/i

        def self.parse(text)
          new(victims: VICTIMS.fetch($~[:kind].downcase)) if LINE.match(text)
        end

        def multi_target? = true
        def distinct_targets? = false
        def target_choices = "[battlefield.controlled_by(controller).creatures, #{victims}]"

        def resolve_call
          <<~RUBY.chomp
            biter, victim = targets
            biter.bite!(victim)
          RUBY
        end
      end
    end
  end
end
