# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target creature you control deals damage equal to its power to target creature or planeswalker."
      # A spell with two targets (`multi_target?`, `resolve!(targets:)`), chosen on casting: the creature
      # you control, then what it damages (`Permanents::Creature#bite!`). One-way, unlike a fight, and the
      # two targets may be the same creature (two instances of "target"). Only instants and sorceries:
      # see EffectList#spell_source.
      #
      # Felling Blow: "Put a +1/+1 counter on target creature you control. Then that creature deals damage equal to
      # its power to target creature an opponent controls." is the same two targets with the counter first
      # (`counter: true`), so the bite counts the counter.
      class Bite < Data.define(:victims, :counter)
        include Effect

        def initialize(victims:, counter: false) = super

        VICTIMS = {
          "creature" => "battlefield.creatures",
          "creature or planeswalker" => "(battlefield.creatures + battlefield.planeswalkers)",
          "creature or planeswalker you don't control" => "(battlefield.not_controlled_by(controller).creatures + battlefield.not_controlled_by(controller).planeswalkers)",
          "creature an opponent controls" => "battlefield.not_controlled_by(controller).creatures"
        }.freeze
        LINE = /\A(?<counter>Put a \+1\/\+1 counter on target creature you control\. Then that creature|Target creature you control) deals damage equal to its power to target (?<kind>#{VICTIMS.keys.join('|')})\.?\z/i

        def self.parse(text)
          new(victims: VICTIMS.fetch($~[:kind].downcase), counter: $~[:counter].start_with?("Put")) if LINE.match(text)
        end

        def multi_target? = true
        def distinct_targets? = false
        def target_choices = "[battlefield.controlled_by(controller).creatures, #{victims}]"

        def resolve_call
          lines = ["biter, victim = targets"]
          lines << %(trigger_effect(:add_counter, counter_type: "+1/+1", target: biter, amount: 1)) if counter
          lines << "biter.bite!(victim)"
          lines.join("\n")
        end
      end
    end
  end
end
