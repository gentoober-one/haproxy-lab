# Projeto de Alta Disponibilidade com Docker, HAProxy e Keepalived

Este projeto demonstra a configuração de um ambiente de alta disponibilidade para servidores web utilizando Docker, HAProxy e Keepalived. Foi desenvolvido como solução para o desafio proposto pelo Professor Almir ao final da aula disponível em: [https://www.youtube.com/watch?v=w6xfWHZZzqI](https://www.youtube.com/watch?v=w6xfWHZZzqI).

## Componentes

O ambiente é composto pelos seguintes serviços Docker:

*   **`appserver1` / `appserver2`**: Dois servidores de aplicação Apache HTTPD que servem uma página HTML simples. Eles operam na porta 80.
*   **`haproxy1` / `haproxy2`**: Duas instâncias do HAProxy configuradas para load balancing do tráfego HTTP e terminação SSL.
    *   `haproxy1` é configurado como MASTER do Keepalived.
    *   `haproxy2` é configurado como BACKUP do Keepalived.
*   **Keepalived**: Utilizado dentro dos contêineres `haproxy1` e `haproxy2` para gerenciar um Endereço IP Virtual (VIP), permitindo o failover automático entre as instâncias do HAProxy.
*   **Docker Compose**: Orquestra a construção e execução de todos os serviços e redes.

## Como Funciona

1.  O `docker compose up -d` inicia todos os serviços definidos no arquivo `docker-compose.yml`.
2.  Uma rede customizada do tipo bridge (`ha_net`) é criada para permitir a comunicação entre os contêineres com IPs estáticos.
3.  O Keepalived, rodando em `haproxy1` (MASTER), assume o Endereço IP Virtual (VIP) `172.28.0.200`.
4.  As requisições externas chegam ao HAProxy através da porta `8443` do host (mapeada para a porta `443` do `haproxy1`).
5.  O HAProxy realiza a terminação SSL (descriptografa o tráfego HTTPS) utilizando os certificados localizados em `./ssl/cert.pem`.
6.  O tráfego HTTP resultante é então balanceado (round-robin) entre `appserver1` (172.28.0.11:80) e `appserver2` (172.28.0.12:80).
7.  **Failover**: Se o contêiner `haproxy1` (MASTER) falhar, o Keepalived no `haproxy2` (BACKUP) detecta a falha e assume o VIP `172.28.0.200`, redirecionando o tráfego para si e mantendo a disponibilidade do serviço. O `haproxy2` então continua a balancear a carga para os appservers.

## Pré-requisitos

*   Docker: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
*   Docker Compose: [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)

## Como Executar

1.  **Clone o repositório**
    ```bash
    git clone https://github.com/gentoober-one/haproxy-lab.git
    cd haproxy-lab
    ```

2.  **Inicie os serviços com Docker Compose:**
    ```bash
    docker compose up -d --build
    ```
    Isso irá construir as imagens (se ainda não construídas) e iniciar todos os contêineres em segundo plano.

3.  **Acesse a aplicação:**
    Abra seu navegador e acesse `https://172.28.0.200/`.
    **Como os certificados são autoassinados, seu navegador exibirá um aviso de segurança. Você precisará aceitar o risco para prosseguir.**

## Testando o Failover

1.  **Verifique qual HAProxy está ativo:**
    Você pode verificar os logs do Keepalived para ver qual instância é a MASTER.
    ```bash
    docker compose logs haproxy1
    docker compose logs haproxy2
    ```
    Procure por mensagens indicando o estado MASTER ou BACKUP. Inicialmente, `haproxy1` deve ser o MASTER.

2.  **Simule uma falha no `haproxy1`:**
    ```bash
    docker compose stop haproxy1
    ```

3.  **Verifique se o `haproxy2` assumiu:**
    Observe os logs do `haproxy2`:
    ```bash
    docker compose logs haproxy2
    ```
    Você deverá ver mensagens indicando que ele transicionou para o estado MASTER e assumiu o VIP.
    A aplicação deve continuar acessível em `https://172.28.0.200/`, agora servida através do `haproxy2`.

4.  **Restaure o `haproxy1` (opcional):**
    ```bash
    docker compose start haproxy1
    ```
    O `haproxy1`, devido à sua prioridade maior, deverá reassumir o estado MASTER após iniciar.

## Estrutura do Projeto

```
.
├── appserver1/
│   ├── Dockerfile
│   └── index.html         # Página servida pelo appserver1
├── appserver2/
│   ├── Dockerfile
│   └── index.html         # Página servida pelo appserver2
├── docker compose.yml     # Arquivo de orquestração do Docker Compose
├── haproxy-custom/
│   ├── Dockerfile             # Dockerfile para a imagem customizada do HAProxy+Keepalived
│   ├── entrypoint.sh        # Script de inicialização para os contêineres HAProxy
│   ├── haproxy.cfg            # Configuração do HAProxy
│   ├── keepalived-backup.conf # Configuração do Keepalived para a instância BACKUP
│   └── keepalived-master.conf # Configuração do Keepalived para a instância MASTER
├── ssl/
│   ├── cert.pem               # Certificado SSL concatenado (certificado + chave) usado pelo HAProxy
│   ├── server.crt             # Certificado do servidor (exemplo)
│   └── server.key             # Chave privada do servidor (exemplo)
└── README.md                # Este arquivo
```

## Certificados SSL

Este projeto utiliza certificados SSL autoassinados localizados no diretório `ssl/`. O arquivo `cert.pem` é uma concatenação do certificado do servidor (`server.crt`) e sua chave privada (`server.key`), conforme esperado pelo HAProxy.

**Para produção, substitua-os por certificados emitidos por uma Autoridade Certificadora (CA) válida.**

## Licença

Este projeto está licenciado sob a **Licença MIT**.
Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## DOAÇÕES:
gentoober@bipa.app (Lightning Network)
