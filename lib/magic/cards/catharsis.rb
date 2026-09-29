module Magic
  module Cards
    class Catharsis < Creature
      card_name "Catharsis"
      cost "{4}{R/W}{R/W}"
      creature_type "Elemental Incarnation"
      power 3
      toughness 4
      evoke "{R/W}{R/W}"

      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      # "When this creature enters, if {W}{W} was spent to cast it, create two 1/1 green and white
      # Kithkin creature tokens."
      class WhiteTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:white, 2)

        def call
          trigger_effect(:create_token, token_class: KithkinToken, amount: 2)
        end
      end

      # "When this creature enters, if {R}{R} was spent to cast it, creatures you control get +1/+1
      # and gain haste until end of turn."
      class RedTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:red, 2)

        def call
          controller.creatures.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 1)
            trigger_effect(:grant_keyword, target: creature, keyword: :haste)
          end
        end
      end

      def etb_triggers = [WhiteTrigger, RedTrigger]
    end
  end
end
