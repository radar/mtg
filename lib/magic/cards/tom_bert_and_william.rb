module Magic
  module Cards
    TomBertAndWilliam = Creature("Tom, Bert, and William") do
      cost "{3}{B}{G}"
      legendary_creature_type "Troll"
      power 5
      toughness 5
    end

    class TomBertAndWilliam < Creature
      # "{1}, Sacrifice another creature: Draw cards equal to the sacrificed creature's power, then discard a card."
      class DrawAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice another creature"

        def resolve!(sacrificed: nil)
          power = Array(sacrificed).first&.power.to_i
          trigger_effect(:draw_cards, number_to_draw: power) if power.positive?
          game.add_choice(Magic::Choice::Discard.new(actor: source, player: controller))
        end
      end

      def activated_abilities = [DrawAbility]

      # "When Tom, Bert, and William die, if they were a creature, return them to the battlefield. They're an artifact.
      # (They're no longer a creature.)"
      class DiesTrigger < TriggeredAbility::Death
        def should_perform?
          event.permanent == actor && actor.creature?
        end

        def call
          card = actor.card
          return unless card.zone&.graveyard?

          returned = card.resolve!(controller: card.owner)
          return unless returned.is_a?(Permanent)

          returned.remove_types(T::Creature, until_eot: false)
          returned.add_types(T::Artifact, until_eot: false)
          returned.apply_continuous_effects!
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
