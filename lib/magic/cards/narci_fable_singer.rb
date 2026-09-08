module Magic
  module Cards
    NarciFableSinger = Creature("Narci, Fable Singer") do
      legendary_creature_type "Human Bard"
      cost generic: 1, white: 1, black: 1, green: 1
      power 3
      toughness 3
      keywords :lifelink
    end

    class NarciFableSinger < Creature
      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent.enchantment? && event.permanent.controller == controller
        end

        def call
          controller.draw!
        end
      end

      class FinalChapterTrigger < TriggeredAbility
        def should_perform?
          event.saga.controller == controller
        end

        def call
          amount = event.saga.mana_value
          opponents.each { |opponent| opponent.lose_life(amount) }
          controller.gain_life(amount)
        end
      end

      def event_handlers
        {
          Events::PermanentSacrificed => SacrificeTrigger,
          Events::FinalChapterResolved => FinalChapterTrigger,
        }
      end
    end
  end
end