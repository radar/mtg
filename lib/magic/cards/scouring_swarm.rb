module Magic
  module Cards
    ScouringSwarm = Creature("Scouring Swarm") do
      cost generic: 1, black: 1, green: 1
      creature_type "Insect"
      power 1
      toughness 1
      keywords :flying
    end

    class ScouringSwarm < Creature
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        power 1
        toughness 1
        colors :black, :green
        keywords :flying
      end

      class LandSacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent.land? && event.permanent.controller == controller
        end

        def call
          if controller.graveyard.cards.lands.count >= 7
            # "...create a tapped token that's a copy of this creature instead."
            copy = ScouringSwarm.new(game: game, owner: controller)
            Permanent.resolve(game: game, owner: controller, card: copy, token: true, copy: true, cast: false, enters_tapped: true)
          else
            trigger_effect(:create_token, token_class: InsectToken, enters_tapped: true)
          end
        end
      end

      def event_handlers
        { Events::PermanentSacrificed => LandSacrificedTrigger }
      end
    end
  end
end