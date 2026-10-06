module Magic
  module Cards
    SilversmoteGhoul = Creature("Silversmote Ghoul") do
      cost generic: 2, black: 1
      creature_type "Zombie Vampire"
      power 3
      toughness 1
    end

    class SilversmoteGhoul < Creature
      # "At the beginning of your end step, if you gained 3 or more life this turn, return this card from your
      # graveyard to the battlefield tapped."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def self.works_from_graveyard? = true

        def should_perform?
          actor.zone&.graveyard? && controllers_end_step? && life_gained_by(controller) >= 3
        end

        def call
          return unless actor.zone&.graveyard?

          Permanent.resolve(game:, card: actor, from_zone: actor.zone, cast: false, enters_tapped: true, controller: actor.owner)
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }

      # "{1}{B}, Sacrifice this creature: Draw a card."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, Sacrifice {this}"

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
