require_relative 'unbounce_page'

# UnbouncePages
#
# Calls the API and extracts page data for a collection of pages.
#
class UnbouncePages
  attr_reader :api_key, :pages
  attr_accessor :company_id

  def initialize(api_interface)
    @api_interface  = api_interface
  end

  def fetch
    json = @api_interface.get(api_uri)
    data = MultiJson.decode(json)
    build_pages(data)
    self
  end

  def as_csv
    CSV.open(file_name, "wb") { |csv| csv << @pages.first.stats.keys }
    CSV.open(file_name, "ab") { |csv| @pages.each { |elem| csv << elem.stats.values.to_a } }
    file_name
  end

  def file_name
    "#{DateTime.now.strftime("%F")}-#{@api_interface.subaccount}-page-export.csv"
  end

  def count
    @pages.count
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/sub_accounts/#{@api_interface.subaccount}/pages?offset=#{@api_interface.offset}&limit=#{@api_interface.limit}")
    end

    def build_pages(data)
      @pages = data['pages'].map { |page_data| UnbouncePage.new(@api_interface, page_data['id']).fetch }
    end

end
