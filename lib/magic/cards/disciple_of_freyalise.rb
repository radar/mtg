module Magic
  module Cards
    # The land back face of Disciple of Freyalise. It has no mana cost.
    GardenOfFreyalise = Card("Garden of Freyalise") do
      type "Land"
    end

    class GardenOfFreyalise < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end

    DiscipleOfFreyalise = Creature("Disciple of Freyalise") do
      cost generic: 3, green: 3
      creature_type "Elf Druid"
      power 3
      toughness 3
      back_face GardenOfFreyalise
    end

    class DiscipleOfFreyalise < Creature
      # "You may sacrifice another creature. If you do, you gain X life and draw X cards, where X is that
      # creature's power." X is read before the sacrifice, while the creature is still on the battlefield.
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice another creature?"

        def resolve!(sacrifice: nil)
          sacrifice ||= candidates.first
          power = sacrifice.power
          super
          actor.controller.gain_life(power)
          power.times { actor.controller.draw! }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = SacrificeChoice.new(actor: actor)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
