require 'awesome_print'
require 'csv'
require 'multi_json'
require 'net/https'
require 'optparse'
require 'uri'

require_relative './models/options'
require_relative './models/api_interface'
require_relative './models/unbounce_page'
require_relative './models/unbounce_pages'


# ------------------------------ Main ------------------------------

# Uses an Unbounce API key and a subaccount ID to extract data about all the
# pages in that subaccount.
#
# Parameters
#
#   Required:
#     --apikey      Your Unbounce API key.
#     --subaccount  The numeric ID of the subaccount that has your pages.
#
#   Optional:
#     --offset      The first page to start from. Defaults to 0
#     --limit       The number of pages to retrieve. Defaults to 50
#
# Examples:
#
#   ruby pages2csv.rb --apikey 07b491ee5a6147d92b143345a48b848f --subaccount 47742 --offset 50 --limit 100
#   ruby pages2csv.rb -k 07b491ee5a6147d92b143345a48b848f -s 47742
#
if __FILE__ == $0
  ai = ApiInterface.new(ARGV)
  up = UnbouncePages.new(ai)
  up.fetch.as_csv

  puts "Wrote #{up.file_name}."
end
