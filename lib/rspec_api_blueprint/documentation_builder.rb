require "rspec_api_blueprint/nested_document"

module DocumentationBuilder

  def self.build(nested_document)
    if Dir.exists?(file_root)
      Dir.glob(File.join(file_root, '*')).each { |f| File.delete(f) }
    else
      Dir.mkdir(file_root)
    end

    nested_document.each do |title, content|
      file_name = title.underscore.gsub(/\s+/, '_')
      File.open("#{file_root}#{file_name}.txt", 'a') do |f|
        f.write DocumentBuilder.new(title, content).build
      end
    end
  end

  class DocumentBuilder

    def initialize(title, content)
      @title = title
      @content = content
    end

    attr_reader :title, :content, :document

    def build
      @document = "# #{title}\n\n" + parse(2, content)
    end

    private

    def parse(level, content)
      case content
        when NestedDocument
          sections = []
          keyword = (content.depth == 3) ? 'Group ' : ''
          content.each do |k,v|
            sections << "#{'#'*level} #{keyword}#{k}\n\n" + parse(level+1, v)
          end
          sections.join
        else
          content
      end
    end

  end

  private

  def self.file_root
    if defined? Rails
      File.join(Rails.root, "/api_docs/")
    else
      File.join(File.expand_path('.'), "/api_docs/")
    end
  end

end


