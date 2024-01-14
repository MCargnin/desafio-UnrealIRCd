# Desafio UnrealIRCd
O IRC (Internet Relay Chat) é um protocolo de comunicação em tempo real baseado em texto, desenvolvido na década de 1980. Ele permite a comunicação entre usuários por meio de salas de bate-papo (chamadas de canais) e mensagens diretas (privado).

No IRC, os usuários se conectam a servidores específicos usando um cliente de IRC (software) e podem participar de diferentes canais de conversa ou criar os seus próprios. Cada canal tem um nome único e pode ter moderadores que ajudam a manter a ordem e aplicam regras específicas.

O desafio consiste na criação de um servidor de IRC, utilizando o UnrealIRCd, e se dará da seguinte forma:

## Rodando o UnrealIRCd em um cloud da Configr

O processo será da seguinte forma:

1) Faça um fork desse repositório e mande o link do repositório para Rodrigo e Gio no gchat;
2) Documente todo o processo, o passo a passo executado, no README;
3) Provisione um novo Cloud usando sua conta da empresa, mas se tiver algum cloud ativo, pode usar;
4) Entregue o IRCd funcional e acessível na porta 6667 no IP do cloud; (Nós iremos acessar através de um cliente de IRC para validar)
5) Com base na configuração de exemplo, o arquivo: ```example.conf```, que consta no repositório, você deverá deixar a rede de IRC com o nome de Configr.

## Diferencial: Criar um  Dockerfile, buildar a imagem sem falhas e executar o UnrealIRCd localhost
Há um arquivo do Dockerfile, porém declarado apenas a imagem do Ubuntu. Será necessário adicionar todas as outras linhas para que o Dockerfile se torne funcional.
Você deverá editar esse Dockerfile para que ele fique válido e builde a imagem do IRCd corretamente em localhost, ou seja, em sua máquina local, e que o IRCd rode localmente na porta 6667. (Você irá apresentar o Dockerfile e seu funcionamento em uma call).

## Documentações
- [Instalação do UnrealIRCd] https://www.unrealircd.org/docs/Installing_from_source
- [Site do UnrealIRCd] https://www.unrealircd.org 
- [Cliente de IRC Linux] https://sempreupdate.com.br/como-instalar-o-irssi-um-cliente-irc-no-ubuntu-linux-mint-fedora-debian/
- [Cliente de IRC Windows] https://www.tlscript.com.br/
- [Dockerfile References] https://docs.docker.com/engine/reference/builder/

# Solução

## Servidor Cloudez

Rodando o UnrealIRCd em uma cloud da Configr

1) Crie uma conta e uma cloud Configr.
2) Aguarde o provisionamento e faça o login na cloud com um usuário com privilégios sudo.
3) Instale todas as dependências necessárias:

```
sudo apt-get install build-essential pkg-config gdb libssl-dev libpcre2-dev libargon2-0-dev libsodium-dev libc-ares-dev libcurl4-openssl-dev
```

4) Crie um novo usuário pelo painel da Configr sem privilégios e faça novo login via SSH. Em nosso caso, utilizaremos o usuário unrealircd.

! Certifique-se de estar na raiz do usuário.

5) Baixe o unrealIRCd e descompacte o pacote

```
mkdir tmp && cd tmp
wget --trust-server-names https://www.unrealircd.org/downloads/unrealircd-latest.tar.gz
cd unrealircd-6.1.4
```

6) Compilando

```
./Config
```

Obs.: Neste ponto podem ser utilizadas as configurações padrão apenas dando enter em todas as perguntas.

```
make
make install
```

7) Ajuste as configurações. Suba o arquivo unrealircd.conf no diretório /home/unrealircd/unrealircd/conf

```
cd /home/unrealircd/unrealircd
```

8) Abra as portas do firewall

```
vim /etc/firewall.d/03_custom
```

```
$IPTABLES -A INPUT -p tcp --dport 6667 -j ACCEPT
$IP6TABLES -A INPUT -p tcp --dport 6667 -j ACCEPT

$IPTABLES -A OUTPUT -p tcp --dport 6667 -j ACCEPT
$IP6TABLES -A OUTPUT -p tcp --dport 6667 -j ACCEPT
```

```
systemctl restart firewall
```

9) Inicie o unrealIRCd

```
cd /home/unrealircd/unrealircd
./unrealircd start
```

## Servidor Docker

1) Construa a imagem a partir do Dockerfile.
```
docker build -t irc-configr .
```

2) Rode a imagem expondo a porta 6667 para seu hospedeiro (tag para remover automaticamente a imagem após parar)
```
docker run -p 6667:6667 --rm irc-configr
```

3) Pare a imagem quando não precisar mais
```
docker stop irc-configr
```

## Instalando o client e conectando nos servidores

1) Abra o terminal e instale o irssi

```
sudo apt-get install irssi
```

2) Execute o client

```
irssi
```

3) Adicione a rede Configr e após, adicione seu servidor

```
/network add configr
/server add -network configr irc.confi.gr 6667
```
Obs.: Neste passo, devemos substituir o irc.confi.gr por nosso FQDN/IP.

4) Conecte na rede

```
/connect configr
```

5) Acesse o canal

```
/join #configr
```
