require 'sinatra'
require 'sinatra/json'
require 'eventbrite-client'

module WIDGET
  class EventbriteAPI < Sinatra::Base
  helpers Sinatra::JSON

    get '/:eid/:level' do
      eb_auth_tokens = {
        app_key: ENV['EB_APP_KEY'],
        user_key: ENV['EB_USER_KEY']
      }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.event_get({ id: params[:eid] })

      level = params[:level].to_i
      level = level-1
      ticket = response['event']['tickets'][level]

      # json :item => ticket
      json :item => "#{ticket['ticket']['quantity_sold']}", :min => { :value => 0 }, :max => { :value => "#{ticket['ticket']['quantity_available']}" }
    end

    get '/students' do
      eb_auth_tokens = {
        app_key: ENV['EB_APP_KEY'],
        user_key: ENV['EB_USER_KEY']
      }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.user_list_events({ only_display: "tickets,id", event_statuses: "live" })
      quantity_sold = 0
      response['events'].each do |e|
        if e['id'] == "14147546693" then
          break
        end

        e['event']['tickets'].each do |t|
          quantity_sold = quantity_sold + t['ticket']['quantity_sold']
        end
      end

      json :item => { :value => "#{quantity_sold}", :text => "Total Number of Students" }
    end

    get '/volunteers' do
      eb_auth_tokens = {
        app_key: ENV['EB_APP_KEY'],
        user_key: ENV['EB_USER_KEY']
      }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.event_get({ only_display: "tickets", event_statuses: "live", id: "14147546693" })
      tickets = response['event']['tickets']
      quantity_sold = 0
      tickets.each do |t|
        quantity_sold = quantity_sold+t['ticket']['quantity_sold'].to_i
      end

      json :item => { :value => "#{quantity_sold}", :text => "Total Number of Volunteers" }
    end
  end
end
