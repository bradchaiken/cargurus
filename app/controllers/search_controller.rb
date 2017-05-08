## Needed to do this to get it to run on heroku: https://gist.github.com/edelpero/9257311 (procfile etc).
class SearchController < ApplicationController

  def index
  end

  def search
    # TEST VIN: "5N1AA0NC9EN606990"
    vin = params[:vin]
    scrape_via_vin(vin)

    if @data_hash[:vin].present?
      redirect_to result_path(@data_hash)
    else
      flash[:alert] = "No results found. Please search again."
      redirect_to root_path
    end
  end

  def result
    @dealer_trade_in_estimate = params[:dealer_trade_in_estimate]
    @instant_market_value     = params[:instant_market_value]
    @profit_over_trade_in     = params[:profit_over_trade_in]
    @vin                      = params[:vin]
    @url                      = params[:url]
    @make                     = params[:make]
    @model                    = params[:model]
    @year                     = params[:year]
  end

  def scrape_via_vin vin
    puts "\n\n" + "fetch cargurus data started..." + "\n\n"

    page_url = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{vin}"
    browser = Watir::Browser.new :phantomjs
    browser.goto page_url
    doc = Nokogiri::HTML.parse(browser.html)
    set_data(doc, page_url, vin)

    puts "\n\n" + "fetch cargurus data concluded" + "\n\n"
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

    ap @data_hash
  end

  private

  def search_params
    params.require(:search).permit(:vin)
  end
end
