# The primary requirement of a Sinatra application is the sinatra gem.
# If you haven't already, install the gem with 'gem install sinatra'
require 'sinatra'
require 'sinatra/reloader'

require 'nokogiri'
require 'open-uri'
require 'openssl'

OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# sinatra allows us to respond to route requests with code.  Here we are 
# responding to requests for the root document - the naked domain.
get '/' do
  p 'Start'
  p Time.now
  # the first two lines are lifted directly from our previous script
  url = 'https://fantasyfootball.telegraph.co.uk/premierleague/players/all'
  data = Nokogiri::HTML(open(url))
  
  # this line has only be adjusted slightly with the inclusion of an ampersand
  # before concerts.  This creates an instance variable that can be referenced
  # in our display logic (view).
  @link_list = []
  data.search('.clubdata tbody tr').first(10).each do |row|
  #data.search('.clubdata tbody tr').each do |row|
    row.search('td').each do |td|
      links = td.css('a')
      unless links[0].nil?
        @link_list.push(links[0]['href'][-4,4])
      end
    end
  end

  @players = []
  @link_list.each do |link|
    player_url = 'https://fantasyfootball.telegraph.co.uk/premierleague/statistics/points/' + link
    player_page = Nokogiri::HTML(open(player_url))
    player = {}
    player['name'] = player_page.search('#stats-name').text
    player['scores'] = []
    player_page.search('#individual-player tbody tr').each do |row|
      i = 0
      score = {}
      row.search('td').each do |cell|
        unless cell.nil?
          score[i.to_s] = cell.text
          i+=1
        end
      end
      player['scores'].push(score)
    end
    @players.push(player)
  end
  p 'End'
  p Time.now
  #p @players.count
  # this tells sinatra to render the Embedded Ruby template /views/players.erb
   erb :players
end