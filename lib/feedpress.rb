require "sinatra"
require "sinatra/json"
require "active_support/core_ext"
require "chronic_duration"
require "chronic"
require "rest_client"

module Feedpress
  class API
    BASE_URL = "http://api.feedpress.it"
    attr_accessor :api_key
    attr_accessor :token

    def base_url
      @base_url || BASE_URL
    end

    def initialize(api_key, token)
      self.api_key = api_key
      self.token = token
    end

    def get(feed, endpoint, to=nil, since=nil)
      params = {
        :feed => feed,
        :token => self.token,
        :key => self.api_key
      }

      if to != nil || since != nil
        params.merge!(to: to)
        params.merge!(since: since)
      end

      begin
        response = RestClient.get "#{BASE_URL}#{endpoint}", {:params => params}
        response
      rescue => e
        puts "There was an error!"
        e.response
      end
    end
  end
end

module WIDGET
  class FeedpressAPI < Sinatra::Base
    helpers Sinatra::JSON

    feed = Feedpress::API.new(ENV['FEEDPRESS_API_KEY'], ENV['FEEDPRESS_TOKEN'])
    get '/count/:feed_name' do

      start_date = Chronic.parse('30 days ago').strftime("%F")
      end_date = Time.new.strftime("%F")
      endpoint = "/feeds/tracking/items.json"

      count = 0

      data = feed.get(params[:feed_name], endpoint, end_date, start_date)
      data = JSON.parse(data)
      data = data['items'].sort_by { |hash| hash['hits'] }.reverse
      data.each do |f|
        count += f['hits'].to_i
      end

      json :item => [{:value => count, :text => params[:feed_name]}]
    end

    get '/list/:feed_name' do
      #want to list to have a limit for the number of items returned back sorted
      #by the most popular and within a timeframe. Sans timeframe show all time
      #which would also be helpful

      start_date = Chronic.parse('30 days ago').strftime("%F")
      end_date = Time.new.strftime("%F")
      endpoint = "/feeds/tracking/items.json"
      limit = params[:limit] || 15

      output = []
      count = 1

      data = feed.get(params[:feed_name], endpoint, end_date, start_date)
      data = JSON.parse(data)
      data = data['items'].sort_by { |hash| hash['hits'] }.reverse
      data.each do |f|
        output << {:title => {:text => f["title"]}, :description => "#{f["hits"]} Downloads"}
        if count >= limit then
          break
        end
        count = count+1
      end

      json :item => output
    end

    get '/subscribers/:feed_name' do
      #just get the subscriber data for the last 30 days and plot it on the
      #chart
      endpoint = '/feeds/subscribers.json'
      limit = params[:limit] || 10

      data = feed.get(params[:feed_name], endpoint)
      data = JSON.parse(data)
      data = data['stats']
      output = []
      count = 1
      current = {:text => "Subscribers", :value => "#{data[0]['greader'] +  data[0]['newsletter']}"}
      data.each do |s|
        output << "#{s['greader'] + s['newsletter']}"
        if count >= limit then
          break
        end
        count = count+1
      end

      json :item => [current , output.reverse]
    end

    get '/subscribers/new/:feed_name' do
      endpoint = '/feeds/subscribers.json'

      data = feed.get(params[:feed_name], endpoint)
      data = JSON.parse(data)
      data = data['stats']
      json :item => [ "value" => "#{data[0]['greader']}", "value" => "#{data[7]['greader']}" ]
    end
  end
end
