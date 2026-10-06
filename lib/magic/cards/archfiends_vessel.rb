module Magic
  module Cards
    ArchfiendsVessel = Creature("Archfiend's Vessel") do
      cost black: 1
      creature_type "Human Cleric"
      keywords :lifelink
      power 1
      toughness 1
    end

    class ArchfiendsVessel < Creature
      DemonToken = Token.create "Demon" do
        creature_type "Demon"
        power 5
        toughness 5
        colors :black
        keywords :flying
      end

      # "When this creature enters, if it entered from your graveyard or you cast it from your graveyard, exile it. If
      # you do, create a 5/5 black Demon creature token with flying."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = this? && event.from&.graveyard?

        def call
          trigger_effect(:exile, target: actor)
          trigger_effect(:create_token, token_class: DemonToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
