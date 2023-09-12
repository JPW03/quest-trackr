# QuestTrackr

Work in progress video game backlog manager with a twist: you can set personal goals (a.k.a Quests) to complete in those games.

It will allow you to make the most out of the games you play, rather than transforming your backlog into a checklist of games to complete like other websites.

All designs for the website are managed on our [Figma](https://www.figma.com/files/project/102626058/Designs?fuid=1270712706134823022)

# How to Build:

  * Clone repo, `git clone https://github.com/JPW03/quest-trackr.git`
  * Run `mix setup` to install and setup dependencies
  * Create `.env` file in root directory with the following values:
  ```
    # IMPORTANT: run 'source .env' in the terminal before running the app to load the environment variables

    # IGDB uses Twitch Oauth for authentication
    # Create an application for your twtich account here: https://dev.twitch.tv/console/apps/
    export TWITCH_CLIENT_ID="insert your client ID"
    export TWITCH_CLIENT_SECRET="insert your client secret"
  ```
  * Run `source .env` in the terminal to load the environment variables into the process
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Once running, the default local URL is [`localhost:4000`](http://localhost:4000).

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
