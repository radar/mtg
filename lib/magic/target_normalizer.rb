module Magic
  module TargetNormalizer
    def normalize_targets(method_name)
      original_method = instance_method(method_name)

      define_method(method_name) do |target: nil, targets: []|
        targets = [target] if target
        resolutions = original_method.bind(self).call(targets: targets)
        target ? resolutions.first : resolutions
      end
    end
  end
end
