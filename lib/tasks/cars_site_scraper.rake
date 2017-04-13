# This task is called by the Heroku scheduler add-on
desc "Hits cars.com and scrapes the data."
task :fetch_cars_site_data => :environment do

  puts "\n\n" + "fetch_cars_site_data started..." + "\n\n"

  @first_name = "Conor"
  @last_name  = "McGregor"
  @full_name  = "#{@first_name} #{@last_name}"

  ## Mechanize Doc's: http://docs.seattlerb.org/mechanize/GUIDE_rdoc.html
  # Initialize new mechanize object
  agent = Mechanize.new
  agent.log = Logger.new "mech.log"
  agent.user_agent = 'Mac Safari'

  # Fetch sherdog.com
  page = agent.get('http://www.sherdog.com/')

  # Grab the search form.
  search_form = page.forms.last

  # Set the search query to the full name of the fighter inputed.
  search_form['q'] = @full_name

  # Submit the search
  page = search_form.submit

  ## Show all links that match the fighters firs and last name.
  puts "\n\n"
  puts "********************************************************************************"
  puts "                            TOP FIGHTER LINKS"
  puts "--------------------------------------------------------------------------------"

  page.links.each do |link|
    if link.text.include? @full_name

      puts "\n"
      ap   link.text
      puts "\n"

    end
  end
  puts "--------------------------------------------------------------------------------"
  puts "                                                                                "
  puts "********************************************************************************"
  puts "\n\n"

  # Set the link found for this fighters name.
  link = page.links.find { |l| l.text == @full_name }

  # Grab and click the link for the fighters url.
  page = page.links.find { |l| l.text == @full_name }.click

  # Get the current page url.
  page = page.uri.to_s

  global_id = page.split('-').last

  # Open page w/ nogogiri to parse data
  doc = Nokogiri::HTML(open(page))

  set_data(doc, page, global_id)

end

def set_data doc, page, global_id
    full_name    = doc.at_css(".fn").text.squish.strip
    nickname     = doc.at_css(".nickname").text.gsub(/"/,'') rescue nil
    birthdate = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[1]/span[1]/span').text rescue nil
    age          = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[1]/span[1]/strong').text rescue nil
    residence    = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[1]/span[2]/strong').text rescue nil
    height       = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[2]/span[1]/strong').text.gsub(/"/,'') rescue nil
    weight       = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[2]/span[2]/strong').text.gsub(/"/,'') rescue nil
    weight_class = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[1]/div[2]/h6/strong/a').text rescue nil
    wins         = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[2]/div/div/div[1]/span[1]/span[2]').text rescue nil
    losses       = doc.xpath('/html/body/div[2]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[2]/div/div/div[2]/span[1]/span[2]').text rescue nil
    no_contests  = doc.xpath('/html/body/div[3]/div[2]/div[1]/section[1]/div/div[1]/div[1]/div/div[2]/div/div[2]/div/span/span[2]').text rescue nil

    # Flatten the array into a hash.
    data_hash = {}

    # Set fighters url
    url = page

    # Add attributes to data_hash.
    data_hash.merge!(
      full_name: full_name,
      nick_name: nickname,
      birt_date: birthdate,
      age: age,
      residence: residence,
      height: height,
      weight: weight,
      weight_class: weight_class,
      wins: wins,
      losses: losses,
      no_contests: no_contests,
      url: url,
      global_id: global_id,
      type: 'mma'
    )

    ap data_hash

    puts "\n\n" + "fetch_cars_site_data concluded" + "\n\n"

    # return data_hash

  end