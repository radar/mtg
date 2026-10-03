module Magic
  module Cards
    ArahboTheFirstFang = Creature("Arahbo, the First Fang") do
      cost generic: 2, white: 1
      legendary_creature_type("Cat Avatar")
      power 2
      toughness 2
    end

    class ArahboTheFirstFang < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Cat"
      end

      def static_abilities = [PowerAndToughnessModification]

      class TribalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && (event.permanent == actor || (!event.permanent.token? && event.permanent.type?("Cat")))
        end

        CatToken = Token.create "Cat" do
          creature_type "Cat"
          power 1
          toughness 1
          colors :white
        end

        def call
          trigger_effect(:create_token, token_class: CatToken)
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => TribalEntersTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
