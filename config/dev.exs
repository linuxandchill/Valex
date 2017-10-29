use Mix.Config

config :stockex, username: System.get_env("INTRINIO_USER")
config :stockex, password: System.get_env("INTRINIO_PW")

