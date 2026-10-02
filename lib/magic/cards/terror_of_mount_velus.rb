module Magic
  module Cards
    TerrorOfMountVelus = Creature("Terror of Mount Velus") do
      cost generic: 5, red: 2
      creature_type("Dragon")
      keywords :flying, :double_strike
      power 5
      toughness 5
    end

    class TerrorOfMountVelus < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:grant_keyword, target: creature, keyword: :double_strike) }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
