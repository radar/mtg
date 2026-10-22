module Magic
  module Cards
    WastescapeBattlemage = Creature("Wastescape Battlemage") do
      cost generic: 1, colorless: 1
      creature_type "Eldrazi Wizard"
      power 2
      toughness 2
    end

    class WastescapeBattlemage < Creature
      # "Kicker {G} and/or {1}{U}"
      def kicker_cost
        @multiple_kickers ||= Costs::MultipleKickers.new({ green: 1 }, { generic: 1, blue: 1 })
      end

      # "...exile target artifact or enchantment an opponent controls."
      class ExileChoice < Magic::Choice::Targeted
        def choices = battlefield.not_controlled_by(controller).select { _1.artifact? || _1.enchantment? }

        def choice_amount = 1

        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          exile_target(target)
        end
      end

      # "...return target creature an opponent controls to its owner's hand."
      class BounceChoice < Magic::Choice::Targeted
        def choices = battlefield.not_controlled_by(controller).creatures

        def choice_amount = 1

        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          bounce(target)
        end
      end

      # "When you cast this spell, if it was kicked with its {G} kicker, exile target artifact or enchantment an opponent controls."
      class GreenKickerTrigger < TriggeredAbility::CastThisSpell
        def should_perform? = spell.kicker_cost.paid?(0)

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "When you cast this spell, if it was kicked with its {1}{U} kicker, return target creature an opponent controls to its owner's hand."
      class BlueKickerTrigger < TriggeredAbility::CastThisSpell
        def should_perform? = spell.kicker_cost.paid?(1)

        def call
          choice = BounceChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [GreenKickerTrigger, BlueKickerTrigger]
    end
  end
end
