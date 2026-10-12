module Magic
  module Cards
    GrayMerchantOfAsphodel = Creature("Gray Merchant of Asphodel") do
      cost generic: 3, black: 2
      creature_type "Zombie"
      power 2
      toughness 4
    end

    class GrayMerchantOfAsphodel < Creature
      # "When this creature enters, each opponent loses X life, where X is your devotion to black. You gain life equal to the
      # life lost this way."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          x = controller.devotion(:black)
          lost = opponents.sum do |opponent|
            actor.trigger_effect(:lose_life, target: opponent, life: x)
            x
          end
          actor.gain_life(lost) if lost.positive?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
