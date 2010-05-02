require 'action_controller'
require 'action_view'
require 'guidance/page'

module Guidance
  class GuideGenerator
    def self.run(input, output)
      GuideGenerator.new(input, output).run
    end

    def initialize(input, output)
      @input = input
      @output = output
    end

    def run
      pages = build_page_list
      FileUtils.mkdir_p @output
      move_artifacts
      
      generate_pages pages
    end

    private
    def markdown(text)
      Kramdown::Document.new(text).to_html
    end

    def build_page_list
      menu = []
      Dir.glob("#{@input}/**/*.md").each do |path|
        path = path.gsub("#{@input}/", '')
        item = Page.new path
        
        if item.depth > 0
          parent = item.parent
          existing_parent = menu.find {|x| x.name == parent.name }

          if not existing_parent.nil?
            parent = existing_parent
          else
            menu << parent
          end

          parent.children << item
        else
          if item.is_index?
            menu.insert 0, item
          else
            menu << item
          end
        end
      end
      
      menu
    end

    def move_artifacts
      artifacts = Dir.glob("#{@input}/**/*.*").select {|x| x !~ /\.md/ }
      artifacts.each do |artifact|
        puts "Copying artifact '#{artifact}'"
        dest = artifact.gsub("#{@input}/", "#{@output}/")
        FileUtils.mkdir_p File.dirname(dest)
        FileUtils.cp artifact, dest
      end
    end

    def generate_pages(pages)
      pages.each do |page|
        if page.has_children?
          page.children.each {|x| generate_page x, pages }
        else
          generate_page page, pages
        end
      end
    end

    def generate_page(page, pages)
      puts "Generating #{page.title}"

      view = ActionView::Base.new @input
      text = IO.read "#{@input}/#{page.src}"
      vars = { :page => page, :pages => pages }
      html = view.render({ :layout => 'layout', :text => markdown(text) }, vars)

      dest = "#{@output}/#{page.url}"
      FileUtils.mkdir_p File.dirname(dest)
      File.open(dest, 'w') do |f|
        f.write html
      end
    end
  end
end
