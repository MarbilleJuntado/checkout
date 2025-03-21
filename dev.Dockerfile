FROM bitwalker/alpine-elixir-phoenix:1.15.0

ARG USER_ID
ARG GROUP_ID

WORKDIR /app

# install npm dependencies
COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm ci

COPY mix.exs .
COPY mix.lock .

CMD mix deps.get && mix phx.server
