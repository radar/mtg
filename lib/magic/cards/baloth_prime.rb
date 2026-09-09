module Magic
  module Cards
    BalothPrime = Creature("Baloth Prime") do
      cost generic: 3, green: 1
      creature_type "Beast"
      power 6
      toughness 6
      enters_tapped
    end

    class BalothPrime < Creature
      BeastToken = Token.create("Beast") do
        creature_type "Beast"
        power 4
        toughness 4
        colors :green
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.add_counter("stun", amount: 6)
        end
      end

      class LifeAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 4),
            Costs::Sacrifice.new(source, source.controller.lands),
          ]
        end

        def resolve!
          controller.gain_life(2)
        end
      end

      class LandSacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent.land? && event.permanent.controller == controller
        end

        def call
          actor.create_token(token_class: BeastToken, enters_tapped: true)
          actor.untap!
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger,
          Events::PermanentSacrificed => LandSacrificedTrigger,
        }
      end

      def activated_abilities = [LifeAbility]
    end
  end
end