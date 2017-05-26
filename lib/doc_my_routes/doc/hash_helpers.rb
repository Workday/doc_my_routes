# Define error classes
module DocMyRoutes
  module HashHelpers
    def deep_merge(first, second)
      merger = proc { |key, f, s| f.is_a?(Hash) && s.is_a?(Hash) ? f.merge(s, &merger) : s }
      first.merge(second, &merger)
    end

    def array_to_hash_keys(arr, default_value = {})
      {}.tap { |hash| arr.each { |key| hash[key] = default_value } }
    end
  end
end
