FROM 943284168373.dkr.ecr.eu-west-1.amazonaws.com/alpine:ruby.3.3.3-slim

#FROM 946573281870.dkr.ecr.eu-west-2.amazonaws.com/alpine:ruby.3.3.3-slim
# FROM 943284168373.dkr.ecr.eu-west-1.amazonaws.com/alpine:ruby3.1.0-slim
 # Install system dependencies required for building Ruby gems
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

#ARG RAILS_MASTER_KEY
RUN gem install rails --version 7.2.2.1
RUN bundle install
RUN VISUAL="mate --wait" bin/rails credentials:edit

# RUN RAILS_ENV=development
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
