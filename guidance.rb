def try_require(lib)
  begin
    require lib
  rescue LoadError
    puts "Could not load '#{lib}'"
  end
end

require 'guidance/vendor/kramdown'

try_require 'active_support'
try_require 'action_pack'

require 'guidance/guide_generator'
