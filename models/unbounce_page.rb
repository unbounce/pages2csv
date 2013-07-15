# UnbouncePage
#
# Calls the API and extracts detailed data about a specific page.
#
class UnbouncePage

  def initialize(api_interface, page_id)
    @api_interface = api_interface
    @page_id       = page_id
    @data          = {}
  end

  def fetch
    json = @api_interface.get(api_uri)
    @data = MultiJson.decode(json)
    self
  end

  def stats
    return if @data.empty?

    curr = tests['current']
    @stats = { id: @page_id, name: name, url: url, visitors: curr['visitors'], conversions: curr['conversions'] }
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/pages/#{@page_id}")
    end

    def method_missing(meth, *args, &block)
      data = @data[meth.to_s]
      data ? data : super
    end
end
