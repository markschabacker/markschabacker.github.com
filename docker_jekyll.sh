#! /bin/bash

#docker run --rm --label=jekyll --name=jekyll --volume=$(pwd):/srv/jekyll -it -p 4000:4000 jekyll/jekyll:pages jekyll serve

docker run --rm \
  --platform linux/amd64 \
  --volume="$PWD:/srv/jekyll:Z" \
  -p 4000:4000 \
  jekyll/jekyll \
  jekyll serve
