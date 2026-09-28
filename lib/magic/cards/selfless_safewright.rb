module Magic
  module Cards
    SelflessSafewright = Creature("Selfless Safewright") do
      creature_type "Elf Warrior"
      cost generic: 3, green: 2
      power 4
      toughness 2
      keywords :flash
      convoke
    end

    class SelflessSafewright < Creature
      # Other permanents you control of the chosen type gain hexproof and indestructible until end of turn.
      class TypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          others = controller.permanents.select { |permanent| permanent != actor && permanent.type?(creature_type) }
          others.each do |permanent|
            trigger_effect(:grant_keyword, target: permanent, keyword: :hexproof)
            trigger_effect(:grant_keyword, target: permanent, keyword: :indestructible)
          end
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(TypeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
