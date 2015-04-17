class NestedDocument < Hash
  def self.new
    super do |hash, key|
      hash[key] = NestedDocument.new
    end
  end

  def +(other)
    other.clone
  end

  def to_s
    String.new
  end

  def max_depth
    return 0 if empty?
    1 + map{ |k,v| v.is_a?(NestedDocument) ? v.max_depth : 0 }.max
  end

  def min_depth
    return 0 if empty?
    1 + map{ |k,v| v.is_a?(NestedDocument) ? v.min_depth : 0 }.min
  end

  def depth
    result = max_depth
    if result == min_depth
      result
    else
      nil
    end
  end

  def path_set(*keys, value)
    keys = keys.clone
    raise PathError, "no path given" if keys.empty?
    key = keys.shift
    if keys.empty?
      self[key] = value
    elsif self[key].is_a? NestedDocument
      self[key].path_set(*keys, value)
    else
      raise PathError, "#{key} : #{self[key]} is not a nested hash"
    end
  end

  def path_get(*keys)
    keys = keys.clone
    raise PathError, "no path given" if keys.empty?
    key = keys.shift
    if keys.empty?
      return self[key]
    elsif self[key].is_a? NestedDocument
      self[key].path_get(*keys)
    else
      raise PathError, "#{key} : #{self[key]} is not a nested hash"
    end
  end

  def path_append(*keys, value)
    existing_value = path_get(*keys)
    new_value = existing_value + value
    path_set(*keys, new_value)
  end

  class PathError < StandardError; end
end