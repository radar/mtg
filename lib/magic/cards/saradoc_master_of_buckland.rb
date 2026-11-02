module Magic
  module Cards
    SaradocMasterOfBuckland = Creature("Saradoc, Master of Buckland") do
      cost generic: 3, white: 1
      legendary_creature_type "Halfling Citizen"
      power 2
      toughness 4
    end

    class SaradocMasterOfBuckland < Creature
      # "Whenever Saradoc or another nontoken creature you control with power 2 or less enters, create a 1/1 white
      # Halfling creature token." Saradoc has power 2, so his own entry matches.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          permanent = event.permanent
          permanent.creature? && !permanent.token? && under_your_control? && permanent.power <= 2
        end

        def call
          create_token(token: Tokens::Halfling)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }

      # "Tap two other untapped Halflings you control: Saradoc gets +2/+0 and gains lifelink until end of turn."
      class PumpAbility < Magic::ActivatedAbility
        def costs
          [Costs::MultiTap.new(2) { controller.creatures.untapped.select { _1.type?("Halfling") && _1 != source } }]
        end

        def resolve!
          pump(source, 2, 0)
          give_keyword(source, :lifelink)
        end
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
