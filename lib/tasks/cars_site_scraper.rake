# This task is called by the Heroku scheduler add-on.
# To Run: 'rake fetch_cars_site_data'
desc "Hits cargurus.com and scrapes the data, given a libray of vins."
task :fetch_cars_site_data => :environment do
  puts "\n\n" + "task started..." + "\n\n"

  # Known vins.
  LIBRARY_OF_VINS = [
    "5N1AA0NC9EN606990",
    "5FNRL5H99BB090042",
    "WAUAH78E17A241895"
  ]

  vins = LIBRARY_OF_VINS

  scrape_via_vins(vins)
  puts "\n\n" + "task started..." + "\n\n"
end

def scrape_via_vins(vins)
  vins.each do |vin|
    puts "\n\n" + "fetch cargurus data started..." + "\n\n"

    page_url = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{vin}"
    browser = Watir::Browser.new :phantomjs
    browser.goto page_url
    doc = Nokogiri::HTML.parse(browser.html)

    set_data(doc, page_url, vin)

    puts "\n\n" + "fetch cargurus data concluded" + "\n\n"
  end
end

def set_data doc, page_url, vin
  instant_market_value     = doc.xpath('//*[@id="priceReport-instantValuePlaceholder"]/h3/span').text.strip rescue nil
  dealer_trade_in_estimate = doc.xpath('//*[@id="priceReport-tradeInValuePlaceholder"]/h3/span').text.strip rescue nil
  profit_over_trade_in     = doc.xpath('//*[@id="priceReport-SellYourCarInfoPlaceholder"]/h3/span').text.strip rescue nil
  make                     = doc.css('.maker-select-dropdown option[@selected="selected"]').text.strip rescue nil
  model                    = doc.css('.model-select-dropdown option[@selected="selected"]').text.strip rescue nil
  year                     = doc.css('.ft-year-selector option[@selected="selected"]').text.strip rescue nil

  @data_hash = {
    instant_market_value: instant_market_value,
    dealer_trade_in_estimate: dealer_trade_in_estimate,
    profit_over_trade_in: profit_over_trade_in,
    vin: vin,
    make: make,
    model: model,
    year: year,
    url: page_url
  }

  car = Car.new(@data_hash)
  car.save
end