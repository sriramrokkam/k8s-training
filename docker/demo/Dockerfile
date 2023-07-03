# Build a cowsay image which prints a default hello world or takes input
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
  cowsay \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/games/cowsay"]
CMD ["hello World"]
