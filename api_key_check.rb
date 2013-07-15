require 'multi_json'
require 'net/https'
require 'optparse'
require 'uri'

require_relative './models/options'
require_relative './models/api_interface'
require_relative './models/unbounce_page'
require_relative './models/unbounce_pages'


# ------------------------------ Main ------------------------------

# Uses an Unbounce API key and a subaccount ID to return the number of
# pages in that subaccount.

if __FILE__ == $0
  ai = ApiInterface.new(ARGV)
  up = UnbouncePages.new(ai)

  puts "Pages: #{up.fetch.count}"
end
