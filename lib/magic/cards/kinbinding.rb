module Magic
  module Cards
    class Kinbinding < Enchantment
      card_name "Kinbinding"
      cost generic: 3, white: 2

      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      # "Creatures you control get +X/+X, where X is the number of creatures that entered the
      # battlefield under your control this turn."
      class Buff < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = controller.creatures

        def power_modification = creatures_entered

        def toughness_modification = creatures_entered

        private

        def creatures_entered
          game.current_turn.events.count do |event|
            event.is_a?(Events::EnteredTheBattlefield) && event.permanent.creature? && event.permanent.controller == controller
          end
        end
      end

      # "At the beginning of combat on your turn, create a 1/1 green and white Kithkin creature token."
      class CombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          trigger_effect(:create_token, token_class: KithkinToken)
        end
      end

      def static_abilities = [Buff]

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
