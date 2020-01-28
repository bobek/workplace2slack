############## Build Stage
FROM elixir:1.9 AS app_builder

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN mix local.hex --force && \
    mix local.rebar --force

# We will build app in /app
RUN mkdir /app
WORKDIR /app

# Copy everything needed
COPY config ./config
COPY lib ./lib
# COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Build the app
RUN mix deps.get
RUN mix deps.compile
# RUN mix phx.digest
RUN mix release

############## Application Stage
FROM debian:stable-slim AS app

ENV LANG=C.UTF-8

# Install dependecies
RUN apt-get update && apt-get install -y openssl libtinfo5

# Copy over the build artifact, run as a non root user
RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
RUN chown -R app ./prod
USER app

EXPOSE 4000/tcp
CMD ["./prod/rel/workplace2slack/bin/workplace2slack", "start"]
