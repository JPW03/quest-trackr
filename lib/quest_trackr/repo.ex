defmodule QuestTrackr.Repo do
  use Ecto.Repo,
    otp_app: :quest_trackr,
    adapter: Ecto.Adapters.Postgres
end
