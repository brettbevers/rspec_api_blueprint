class NestedHash < Hash
  def self.new
    super do |hash, key|
      hash[key] = NestedHash.new
    end
  end

  def +(other)
    case other
      when String
        other
      else
        super
    end
  end

  def max_depth
    1 + map{ |k,v| v.is_a?(NestedHash) ? v.max_depth : 0 }.max
  end

  def min_depth
    1 + map{ |k,v| v.is_a?(NestedHash) ? v.min_depth : 0 }.min
  end

  def depth
    result = max_depth
    if result == min_depth
      result
    else
      nil
    end
  end

  def set_path(*keys, value)
    keys.compact!
    raise PathError, "no path given" if keys.empty?
    key = keys.shift
    if keys.empty?
      self[key] = value
    elsif self[key].is_a?(NestedHash)
      self[key].set_path(*keys, value)
    else
      raise PathError, "#{key} : #{self[key]} is not a nested hash"
    end
  end

  class PathError < StandardError; end
end