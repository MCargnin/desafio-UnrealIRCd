FROM ubuntu:18.04

# Modo não interativo
ENV DEBIAN_FRONTEND noninteractive

# Atualizar e instalar pacotes necessários
RUN apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean
# Pacotes utilizados
RUN apt-get install -y wget && apt-get install -y make && apt-get install -y openssl 
# Pacotes solicitados pela documentação
RUN apt-get install -y build-essential pkg-config gdb libssl-dev libpcre2-dev libargon2-0-dev libsodium-dev libc-ares-dev libcurl4-openssl-dev
RUN apt-get update && apt-get upgrade -y

# Cria o user
RUN adduser unrealircd

# Altera o user e o diretório de trabalho
USER unrealircd
WORKDIR /home/unrealircd/

# Baixa o arquivo
RUN wget --trust-server-names https://www.unrealircd.org/downloads/unrealircd-latest.tar.gz
RUN tar -xzvf unrealircd-6.1.4.tar.gz

WORKDIR /home/unrealircd/unrealircd-6.1.4

# Configura e compila
RUN ./Config && make && make install

# Adiciona o arquivo de configuração
COPY unrealircd.conf /home/unrealircd/unrealircd/conf/
# Copia o arquivo de configuração OpenSSL para dentro do contêiner
COPY openssl.cnf /etc/ssl/openssl.cnf
WORKDIR /home/unrealircd/unrealircd/

# Gera a chave privada do servidor usando openssl req e inclui as configurações do openssl.cnf
RUN openssl req -newkey rsa:2048 -nodes -keyout /home/unrealircd/unrealircd/conf/tls/server.key.pem -x509 -days 365 -out /home/unrealircd/unrealircd/conf/tls/server.cert.pem -config /etc/ssl/openssl.cnf -subj "/CN=confi.gr"

# Expõe porta do container
EXPOSE 6667
EXPOSE 6697
EXPOSE 6900

# Inicia o unrealIRCd com a imagem e mantém em execução indefinidamente
CMD ["sh", "-c", "./unrealircd start && tail -f /dev/null"]
