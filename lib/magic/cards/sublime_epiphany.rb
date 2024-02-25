module Magic
  module Cards
    class SublimeEpiphany < Instant
      card_name "Sublime Epiphany"
      cost generic: 5, blue: 1

      class CounterTargetSpell < Mode
        def target_choices
          game.stack.spells
        end

        def resolve!(target:)
          trigger_effect(:counter_spell, target: target)
        end
      end

      class CounterTargetActivatedOrTriggeredAbility < Mode
        def target_choices
          game.stack.abilities
        end

        def resolve!(target:)
          trigger_effect(:counter_ability, target: target)
        end
      end

      modes CounterTargetSpell, CounterTargetActivatedOrTriggeredAbility
    end
  end
end
