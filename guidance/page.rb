module Guidance
  class Page
    attr_reader :children

    def initialize(path)
      @path = path
      @children = []
    end

    def src
      @path
    end

    def is_index?
      depth == 0 and @path =~ /index\.md/
    end

    def has_children?
      not @children.empty?
    end

    def title
      return nil if is_index?

      name = @path.gsub('.md', '')
      name = name.gsub('_', ' ')
      name.split('/').join(': ')
    end

    def depth
      @path.split('/').length - 1
    end

    def url
      @path.gsub('.md', '.htm')
    end

    def name
      return 'Home' if is_index?

      name = @path.gsub('.md', '')
      name = name.gsub('_', ' ')
      name.split('/').last
    end

    def parent
      item = @path.split('/').first
      return nil if item.nil?
      Page.new item
    end
  end
end
