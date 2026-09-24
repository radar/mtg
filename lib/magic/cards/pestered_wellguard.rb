module Magic
  module Cards
    PesteredWellguard = Creature("Pestered Wellguard") do
      cost generic: 3, blue: 1
      creature_type("Merfolk Soldier")
      power 3
      toughness 2
    end

    class PesteredWellguard < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        FaerieToken = Token.create "Faerie" do
          creature_type "Faerie"
          power 1
          toughness 1
          colors :blue, :black
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: FaerieToken)
        end
      end

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }
    end
  end
end
