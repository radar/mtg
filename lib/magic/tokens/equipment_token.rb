module Magic
  module Tokens
    # Builds a colorless Equipment artifact token ("Create a colorless Equipment artifact token named
    # Sword with 'Equipped creature gets +1/+1' and equip {2}"). Assign the result to a constant:
    #
    #   Sword = EquipmentToken.build("Sword", power: 1, toughness: 1, equip: "{2}")
    module EquipmentToken
      # What a permanent asks of anything attached to it (see Cards::Attachment); an Equipment token
      # grants nothing beyond its static abilities.
      module AttachmentDefaults
        def keyword_grants = []
        def type_grants = []
        def grants_all_creature_types? = false
        def assigns_toughness_damage?(_creature) = false
        def power_modification = 0
        def toughness_modification = 0
        def does_not_untap_during_untap_step? = false
        def prevents_untapping? = false
        def prevents_counters? = false
      end

      def self.build(name, power:, toughness:, keywords: [], equip: "{2}", legendary: false)
        types = [*(T::Super::Legendary if legendary), T::Artifact, "Equipment"]
        token = Token.create(name) do
          type(*types)
          power 0
          toughness 0
          include AttachmentDefaults
        end

        buff = Class.new(Abilities::Static::PowerAndToughnessModification) do
          modify power: power, toughness: toughness
          applies_to_target
        end
        token.const_set(:Buff, buff)
        statics = [buff]

        if keywords.any?
          grant = Class.new(Abilities::Static::KeywordGrant) do
            keyword_grants(*Cards::Keywords.list(*keywords))
            applies_to_target
          end
          token.const_set(:Grant, grant)
          statics << grant
        end

        equip_ability = Class.new(ActivatedAbility) do
          costs equip
          activate_only_as_sorcery

          def target_choices = battlefield.controlled_by(controller).creatures

          def resolve!(target:)
            source.attach_to!(target)
          end
        end
        token.const_set(:EquipAbility, equip_ability)

        token.define_method(:static_abilities) { statics }
        token.define_method(:activated_abilities) { [equip_ability] }
        token
      end
    end
  end
end
