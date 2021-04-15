FROM ruby:2.6

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libxml2-dev libxslt-dev

RUN mkdir -p /www/app
WORKDIR /www/app

ENV RAILS_ENV=production

COPY Gemfile* ./
RUN bundle install

COPY . ./

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]