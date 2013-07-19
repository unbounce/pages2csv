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
#
# Parameters
#
#   Required:
#     --apikey      Your Unbounce API key.
#     --subaccount  The numeric ID of the subaccount that has your pages.
#
# Examples:
#
#   ruby api_key_check.rb --apikey 07b491ee5a6147d92b143345a48b848f --subaccount 47742
#   ruby api_key_check.rb -k 07b491ee5a6147d92b143345a48b848f -s 47742
#
if __FILE__ == $0
  ai = ApiInterface.new(ARGV)
  up = UnbouncePages.new(ai)

  puts "Pages: #{up.fetch.count}"
end
