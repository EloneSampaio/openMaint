# OpenMaint com Docker Compose

Este repositório contém um ambiente Docker Compose para rodar o OpenMaint, uma solução de gerenciamento de ativos e manutenção baseada no CMDBuild. O ambiente inclui:

- **OpenMaint:** Aplicação principal para gerenciamento de ativos e manutenção.
- **Postgis:** Extensão do postgresql para operações com dados espacias.
- **pgAdmin:** Interface gráfica para gerenciamento do banco de dados PostgreSQL.

## Pré-requisitos

Antes de começar, certifique-se de que você tem instalado:

- **Docker:** [Guia de instalação](https://docs.docker.com/get-docker/)
- **Docker Compose:** [Guia de instalação](https://docs.docker.com/compose/install/)

## Como Usar

### Passo 1: Clone o Repositório

Clone este repositório ou crie um arquivo `docker-compose.yml` com o conteúdo abaixo:

```yaml
version: "3.3"

volumes:
  openmaint-db:
  openmaint-tomcat:
  pgadmin-data:

services:
  openmaint_db:
    image: postgis/postgis:12-3.3-alpine
    container_name: openmaint_db
    volumes:
      - openmaint-db:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    restart: always

  openmaint_app:
    image: elonesampaio/openmaint-om-2.3-3.4.1:latest
    container_name: openmaint_app
    links:
      - openmaint_db
    depends_on:
      - openmaint_db
    ports:
      - "${OPENMAINT_PORT}:8080"
    restart: always
    volumes:
      - openmaint-tomcat:/usr/local/tomcat
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASS: ${POSTGRES_PASSWORD}
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_HOST: ${POSTGRES_HOST}
      POSTGRES_DB: ${POSTGRES_DB}
      JAVA_OPTS: ${JAVA_OPTS}
      CMDBUILD_DUMP: ${CMDBUILD_DUMP}

  pgadmin:
    image: dpage/pgadmin4
    container_name: pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    ports:
      - "${PGADMIN_PORT}:80"
    volumes:
      - pgadmin-data:/var/lib/pgadmin
    restart: always
```

# Passo 2: Crie o Arquivo .env

Crie um arquivo chamado .env no mesmo diretório do docker-compose.yml e adicione as seguintes variáveis de ambiente:

### Configurações do PostgreSQL
- POSTGRES_USER=openmaint
- POSTGRES_PASSWORD=senha_segura
- POSTGRES_PORT=5432
- POSTGRES_HOST=seuip
- POSTGRES_DB=openmaint

### Configurações do OpenMaint
- OPENMAINT_PORT=8090
- JAVA_OPTS=-Xmx4000m -Xms2000m
- CMDBUILD_DUMP=empty.dump.xz

### Configurações do pgAdmin
- PGADMIN_EMAIL=admin@example.com
- PGADMIN_PASSWORD=senha_segura
- PGADMIN_PORT=5050

# Passo 3: Inicie os Contêineres

No diretório onde estão o docker-compose.yml e o .env, execute:

docker-compose up -d

Isso iniciará os contêineres do OpenMaint, PostgreSQL e pgAdmin.


# Passo 4: Crie o Banco de Dados e o Usuário no PostgreSQL
Se o banco de dados e o usuário não forem criados automaticamente, você pode configurá-los manualmente. 

```yaml
CREATE DATABASE openmaint;
CREATE USER openmaint WITH ENCRYPTED PASSWORD 'demopass@2024';
GRANT ALL PRIVILEGES ON DATABASE openmaint TO openmaint;
\q
```

# Passo 5: Acesse o pgAdmin

Abra o navegador e acesse:

- http://localhost:5050

Faça login com as credenciais:

- Email: admin@example.com
- Senha: senha_segura

#### Adicionando o Servidor PostgreSQL

Clique em Add New Server.
1. Na aba General, insira um nome para o servidor (ex: OpenMaint DB).
2. Na aba Connection, insira os detalhes:
3. Host: openmaint_db
4. Port: 5432
5. Maintenance Database: postgres
6. Username: openmaint_user
7. Password: senha_segura
8. Clique em Save.

# Passo 6: Restaure o Arquivo empty.dump.xz (Opcional)
Baixe o arquivo o arquivo empty.dump.xz  para restaurar o banco de dados, siga estas etapas:
 - https://sourceforge.net/projects/openmaint/files/2.3/openmaint-2.3-3.4.1-d.war/

1. Descompacte o Arquivo

2. Restaure o Dump no Banco de Dados:

1. No pgAdmin, clique com o botão direito no banco de dados openmaint.
2. Selecione Restore.
3. No campo Filename, selecione o arquivo empty.dump.
3. Em Role name, selecione o usuário openmaint.
4. Clique em Restore.

##### Aguarde a Restauração:

O pgAdmin exibirá um log de progresso. Aguarde até que o processo seja concluído(~50min).

# Passo 7: Acesse o OpenMaint

Abra o navegador e acesse:

- http://localhost:8090/cmdbuild

# Links Úteis
- [OpenMaint](https://www.openmaint.org/)
- [CMDBuild](https://www.cmdbuild.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [pgAdmin](https://www.pgadmin.org/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [PostGIS](https://postgis.net/)
- [Docker Hub](https://hub.docker.com/)
- [SourceForge](https://sourceforge.net/projects/openmaint/files/2.3/openmaint-2.3-3.4.1-d.war/)
- [OpenMaint Docker](https://hub.docker.com/r/elonesampaio/openmaint-om-2.3-3.4.1)

# Contribuição
Se você encontrar problemas ou tiver sugestões de melhorias, sinta-se à vontade para abrir uma issue ou enviar um pull request.

# Licença
Este projeto está licenciado sob a MIT License.

# Contato
Para mais informações, entre em contato:

- Email: gomcalsam@gmail.com
- GitHub: elonesampaio
