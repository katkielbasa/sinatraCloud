# Building a docker image

```bash
docker build -t my-ruby-app .
```

# Running

## Start postgres container

```bash
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

## Start the container running `my-ruby-app` and link it to the postgres container

```bash
docker run -it --link some-postgres:postgres --env DATABASE_URL=postgres://postgres:mysecretpassword@postgres:5432 -p 9292:9292 --name my-running-script -d my-ruby-app
```
