FROM golang
RUN mkdir /app
RUN mkdir /config
ADD . /app/
WORKDIR /app
RUN go build -o main .
CMD ["/app/main", "-out", "/config/target.json"]
