# Mostly taken from http://qiita.com/masuidrive/items/1042d93740a7a72242a3

require 'sinatra/base'
require 'json'
require 'rest-client'

class App < Sinatra::Base

  # メッセージを投稿する関数
  def line_post(content_json)
    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']
    RestClient.post(endpoint_uri, content_json, {
      'Content-Type' => 'application/json; charset=UTF-8',
      'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
      'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
      'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
    })
  end

  to_id = ENV['LINE_TO_ID']

  # メッセージ受信時に呼ばれるAPI
  # オウム返しを行う
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }
      content_json = request_content.to_json
      line_post(content_json)
    end

    "OK"
  end

  # メッセージの投稿を行うGETのAPI
  get '/linebot/message/:text' do
    content = {
      contentType: 1,
      toType: 1,
      "text": params[:text]
    }

    request_content = {
      to: [to_id],
      toChannel: 1383378250, # Fixed value
      eventType: "138311608800106203", # Fixed value
      content: content
    }

    content_json = request_content.to_json
    line_post(content_json)
    return params[:text]
  end

  # メッセージの投稿を行うPOSTのAPI
  post '/linebot/post' do
    params = JSON.parse(request.body.read)

    content = {
      contentType: 1,
      toType: 1,
      "text": params['text'].gsub(/(,)/, "\n")
    }

    request_content = {
      to: [to_id],
      toChannel: 1383378250, # Fixed  value
      eventType: "138311608800106203", # Fixed value
      content: content
    }

    content_json = request_content.to_json
    line_post(content_json)
    "OK"
  end

end
