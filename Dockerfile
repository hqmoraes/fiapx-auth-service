FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY go.mod go.sum ./
RUN go mod download

# Copiar código fonte
COPY . .

# Compilar a aplicação
# Cross-build arguments
ARG TARGETOS
ARG TARGETARCH
# Switch to service folder for build
WORKDIR /app/cmd/auth-service
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -installsuffix cgo -o /app/auth-service .

# Imagem final
FROM alpine:3.18

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copiar o binário compilado
COPY --from=builder /app/auth-service .

# Expor porta
EXPOSE 8081

# Comando para executar a aplicação
CMD ["./auth-service"]
