module Magic
  module Cards
    WoodlandWeavemaster = Creature("Woodland Weavemaster") do
      cost generic: 1, green: 1
      creature_type "Elf Druid"
      keywords :vigilance
      power 1
      toughness 2
    end

    class WoodlandWeavemaster < Creature
      # "Whenever another Elf you control enters, this creature gets +1/+1 until end of turn."
      class ElfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent != actor && event.permanent.type?("Elf") && under_your_control?
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 1)
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => ElfEntersTrigger }) { |_, old, new| [*old, *new] }

      # "{T}: Add X mana of any one color, where X is this creature's power. Spend this mana only to cast Elf spells and
      # activate abilities of Elf sources."
      class AddMana < Magic::TapManaAbility
        choices :all

        def mana_produced = { choice => source.power }

        def mana_restriction = ManaRestriction::OfType.new(type: "Elf")
      end

      def activated_abilities = [AddMana]
    end
  end
end
