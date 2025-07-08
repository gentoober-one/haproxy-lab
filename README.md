# Projeto de Alta Disponibilidade com Docker, HAProxy, ModSecurity (WAF) e Keepalived

Este projeto demonstra a configuração de um ambiente de alta disponibilidade para servidores web utilizando Docker, HAProxy, um WAF (Nginx + ModSecurity CRS) e Keepalived. Foi desenvolvido como solução para o desafio proposto pelo Professor Almir ao final da aula disponível em: [https://www.youtube.com/watch?v=w6xfWHZZzqI](https://www.youtube.com/watch?v=w6xfWHZZzqI).

## Componentes

O ambiente é composto pelos seguintes serviços Docker:

*   **`appserver1` / `appserver2`**: Dois servidores de aplicação (Apache HTTPD) que servem uma página HTML simples. Operam na porta 80.
*   **`waf`**: Container Nginx com ModSecurity e OWASP CRS, atuando como Web Application Firewall. Todo o tráfego dos HAProxy passa por ele antes de chegar aos appservers.
*   **`haproxy1` / `haproxy2`**: Duas instâncias do HAProxy configuradas para load balancing do tráfego HTTPS e terminação SSL.
    *   `haproxy1` é configurado como MASTER do Keepalived.
    *   `haproxy2` é configurado como BACKUP do Keepalived.
*   **Keepalived**: Utilizado dentro dos contêineres `haproxy1` e `haproxy2` para gerenciar um Endereço IP Virtual (VIP), permitindo o failover automático entre as instâncias do HAProxy.
*   **Docker Compose**: Orquestra a construção e execução de todos os serviços e redes.

## Como Funciona

1.  O `docker compose up -d` inicia todos os serviços definidos no arquivo `docker-compose.yml`.
2.  Uma rede customizada do tipo bridge (`ha_net`) é criada para permitir a comunicação entre os contêineres com IPs estáticos.
3.  O Keepalived, rodando em `haproxy1` (MASTER), assume o Endereço IP Virtual (VIP) `172.28.0.200`.
4.  As requisições externas chegam ao HAProxy através da porta `443` (ou `8443` do host, se mapeado).
5.  O HAProxy realiza a terminação SSL utilizando os certificados localizados em `./ssl/cert.pem`.
6.  O tráfego HTTP resultante é encaminhado para o container `waf`, que inspeciona e protege contra ataques usando ModSecurity CRS.
7.  O WAF encaminha o tráfego limpo para os appservers (`appserver1` e `appserver2`).
8.  **Failover**: Se o contêiner `haproxy1` (MASTER) falhar, o Keepalived no `haproxy2` (BACKUP) detecta a falha e assume o VIP `172.28.0.200`, mantendo a disponibilidade do serviço.

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

## Testando o WAF (ModSecurity)

1. **Acesso normal:**
    ```bash
    curl -k https://172.28.0.200/
    ```
    Deve retornar a página normalmente.

2. **Teste de ataque XSS (deve ser bloqueado):**
    ```bash
    curl -k "https://172.28.0.200/?q=<script>alert(1)</script>"
    ```
    Deve retornar HTTP 403 Forbidden.

3. **Verifique os logs do WAF:**
    ```bash
    docker compose logs waf
    ```
    Os bloqueios e detecções do ModSecurity aparecerão nos logs do container.

## Estrutura do Projeto

```
.
├── appserver1
│   ├── Dockerfile
│   └── index.html
├── appserver2
│   ├── Dockerfile
│   └── index.html
├── docker-compose.yml
├── haproxy-custom
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── haproxy.cfg
│   ├── keepalived-backup.conf
│   └── keepalived-master.conf
├── LICENSE
├── README.md
├── ssl
│   ├── cert.pem
│   ├── server.crt
│   └── server.key
└── waf
    ├── default.conf
    ├── Dockerfile
    ├── modsecurity.conf
    ├── nginx.conf
    └── unicode.mapping
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
