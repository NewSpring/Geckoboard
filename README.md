#Geckoboard Widgets

Here at [NewSpring](https://newspring.cc) we use Geckoboard for monitoring a lot of the different areas that concern our presence on the internet. Everything from internet traffic to the number of subscribers on our podcast. For the most part, Geckoboard has all the integrations built in. But there are a few services we use that we needed to write our own custom integrations.

##Installation

This is a basic Sinatra app.  It was written to work on Heroku but you could run it anywhere.

##Wufoo

I'm using the WuParty gem.  This gem contains a `count` method that accepts filters. You can read more about filters and Wufoo's API on their [website](http://wufoo.com/docs/api/v3/entries/get/#filter).

    $ heroku config:add FORM=form-name
    $ heroku config:add ACCOUNT=account
    $ heroku config:add API_KEY=S5JI-IDSF-SDFS-DSFD #Not a real key

After you deploy the app you should just be able to added the heroku URL to geckoboard as a custom widget.  Make sure its set to polling and I would up the refresh to a high number so you don't hit Wufoo API Limits (5000/day).

##Ooyala

We use Ooyala to host our video content. This aspect of the app just pulls in specific metrics from their analytics API.

You'll need to add your credentials to the ENV variable to make it work.

    $ heroku config:add OOYALA_API_KEY=api_key
    $ heroku config:add OOYALA_SECRET_KEY=api_secret

Enjoy!
