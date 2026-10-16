module Magic
  module Cards
    class SaplingNursery < Enchantment
      card_name "Sapling Nursery"
      cost "{6}{G}{G}"

      affinity("Forest")

      TreefolkToken = Token.create "Treefolk" do
        creature_type "Treefolk"
        power 3
        toughness 4
        colors :green
        keywords :reach
      end

      # "Landfall -- Whenever a land you control enters, create a 3/4 green Treefolk creature token
      # with reach."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = event.player == controller

        def call
          create_token(token:TreefolkToken)
        end
      end

      # "{1}{G}, Exile this enchantment: Treefolk and Forests you control gain indestructible until
      # end of turn."
      class ProtectAbility < Magic::ActivatedAbility
        costs "{1}{G}, Exile {this}"

        def resolve!
          controller.permanents.select { _1.type?("Treefolk") || _1.type?("Forest") }.each(&:grant_indestructible!)
        end
      end

      def activated_abilities = [ProtectAbility]

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
