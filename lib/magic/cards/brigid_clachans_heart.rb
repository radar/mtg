module Magic
  module Cards
    class BrigidDounsMind < Creature
      card_name "Brigid, Doun's Mind"
      legendary_creature_type "Kithkin Soldier"
      color_indicator :green
      power 3
      toughness 2

      # "{T}: Add X {G} or X {W}, where X is the number of other creatures you control."
      class ManaAbility < Magic::TapManaAbility
        choices :green, :white

        def mana_produced
          { choice => controller.creatures.except(source).count }
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay white: 1
      end

      def activated_abilities = [ManaAbility]

      def event_handlers
        { Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class BrigidClachansHeart < Creature
      card_name "Brigid, Clachan's Heart"
      cost generic: 2, white: 1
      legendary_creature_type "Kithkin Warrior"
      power 3
      toughness 2
      back_face BrigidDounsMind

      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      # "Whenever this creature enters or transforms into Brigid, Clachan's Heart, create a 1/1
      # green and white Kithkin creature token."
      class KithkinTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          trigger_effect(:create_token, token_class: KithkinToken)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = KithkinTrigger.new(event:, actor:).call
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay green: 1
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::PermanentTransformed => KithkinTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
