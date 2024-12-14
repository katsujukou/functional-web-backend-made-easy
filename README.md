# Functional Web Backend Development Made Easy

## How to Start

Note: You need a working PureScript environment.
Specifically, ensure that `purs`, `spago@next`, and `purs-backend-es` are available on your machine.
If you're using Nix, simply enter the development shell by running `nix develop`.

```sh
npm run build
docker compose up
```

Now you can play with sample api server.

### Create Post

```sh
curl -XPOST "http://localhost:3000/api/posts" \
  -H 'Content-Type:application/json' \
  -d '{ "title": "My Blog Post 1", "body": "This is my first awesome blog post!" }'
```

### List Posts

```sh
curl "http://localhost:3000/api/posts"
```
