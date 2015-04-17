class Example

  ACTION_REGEXP = /\[(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS|CONNECT|PATCH)\]/i

  def initialize(example)
    @example = example
  end

  attr_reader :example

  def levels
    @levels ||=
        example_groups.reverse.
            map{ |group| group[:description_args].first }.
            take_while{ |description| !(ACTION_REGEXP === description)  }
  end

  def description
    example.description
  end

  def headers
    example.metadata[:headers]
  end

  private

  def example_groups
    @example_groups ||= Array.new.tap do |example_groups|
      example_group = example.metadata[:example_group]
      while example_group
        example_groups << example_group
        example_group = example_group[:example_group]
      end
    end
  end

end