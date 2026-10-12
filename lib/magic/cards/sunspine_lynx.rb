module Magic
  module Cards
    SunspineLynx = Creature("Sunspine Lynx") do
      cost generic: 2, red: 2
      creature_type("Elemental Cat")
      power 5
      toughness 4
    end

    class SunspineLynx < Creature
      # Players can't gain life. Damage can't be prevented.
      class Restrictions < StaticAbility
        attr_reader :source

        def prevents_life_gain?(_player) = true

        def damage_cant_be_prevented? = true
      end

      def static_abilities = [Restrictions]

      # When this creature enters, it deals damage to each player equal to the number of nonbasic lands that
      # player controls.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.players.each do |player|
            count = player.lands.reject(&:basic_land?).count
            deal_damage(count, to: player) if count.positive?
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
