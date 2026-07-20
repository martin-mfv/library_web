FROM ruby:3.4

RUN apt-get update -qq && apt-get install -y postgresql-client

# Node 22 LTS + Yarn (esbuild / Tailwind need Node)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /myapp
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
