module Magic
  module Cards
    RavenhillFlock = Creature("Ravenhill Flock") do
      cost generic: 3, blue: 1
      creature_type("Bird")
      keywords :flying
      power 1
      toughness 2
    end

    class RavenhillFlock < Creature
      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          add_counter("+1/+1", to: actor)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => CardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
