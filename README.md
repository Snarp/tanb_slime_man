# tanb.......slime man

A Sinatra-based Tumblr client that re-enables stable dashboard pagination but does BASICALLY nothing else.

## LOCAL SETUP

1. Set `TUMBLR_CONSUMER_KEY`, `TUMBLR_CONSUMER_SECRET`, and `SESSION_SECRET` in `_env`. (A Tumblr consumer key and secret can be acquired by registering an application at <https://www.tumblr.com/oauth/apps>; a session secret should be generated randomly for each device you deploy the app on.)

2. Rename `_env` to `.env`.

3. Run command:

```bash
bundle exec shotgun config.ru
```

## HEROKU DEPLOYMENT

1. Push to Heroku:

```bash
heroku create
git push heroku master
```

2. Set Heroku config variables `TUMBLR_CONSUMER_KEY`, `TUMBLR_CONSUMER_SECRET`, and `SESSION_SECRET`. This can be done either via the Heroku app dashboard, or using the CLI:

```bash
heroku config:set TUMBLR_CONSUMER_KEY=...
heroku config:set TUMBLR_CONSUMER_SECRET=...
heroku config:set SESSION_SECRET=...
```

## ORIGINAL TEMPLATE CLONED FROM

<http://os.alfajango.com/heroku-sinatra-mvc/>

<git://github.com/JangoSteve/heroku-sinatra-app.git>

