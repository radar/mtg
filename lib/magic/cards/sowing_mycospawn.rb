module Magic
  module Cards
    SowingMycospawn = Creature("Sowing Mycospawn") do
      cost generic: 3, green: 1
      creature_type "Eldrazi Fungus"
      power 3
      toughness 3
      keywords :devoid
      kicker_cost generic: 1, colorless: 1
    end

    class SowingMycospawn < Creature
      # "When you cast this spell, search your library for a land card, put it onto the battlefield, then shuffle."
      class SearchTrigger < TriggeredAbility::CastThisSpell
        def call
          game.search_library(actor, find: :lands, to: :battlefield)
        end
      end

      # "...exile target land."
      class ExileLandChoice < Magic::Choice::Targeted
        def choices = battlefield.lands

        def choice_amount = 1

        # Mandatory: declining takes the default of the first legal land.
        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          exile_target(target)
        end
      end

      # "When you cast this spell, if it was kicked, exile target land."
      class KickedTrigger < TriggeredAbility::CastThisSpell
        def should_perform? = spell.kicker_cost.paid?

        def call
          choice = ExileLandChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [SearchTrigger, KickedTrigger]
    end
  end
end
