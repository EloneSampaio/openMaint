FROM tomcat:9.0.71-jdk17-temurin

WORKDIR $CATALINA_HOME

# Variáveis de ambiente com valores padrão
ENV CMDBUILD_URL=https://sourceforge.net/projects/openmaint/files/2.3/openmaint-2.3-3.4.1-d.war/download
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_HOST=openmaint_db
ENV POSTGRES_DB=openmaint

# Instala dependências
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        maven \
        postgresql-client \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Cria diretórios necessários
RUN mkdir -p $CATALINA_HOME/conf/cmdbuild/ \
    && mkdir -p $CATALINA_HOME/webapps/cmdbuild/

# Copia arquivos de configuração
COPY files/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
COPY files/context.xml $CATALINA_HOME/webapps/manager/META-INF/context.xml
COPY files/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Baixa e configura o OpenMaint
RUN set -x \
    && groupadd tomcat \
    && useradd -s /bin/false -g tomcat -d $CATALINA_HOME tomcat \
    && cd /tmp \
    && wget --no-check-certificate -O cmdbuild.war "$CMDBUILD_URL" \
    && unzip cmdbuild.war -d cmdbuild \
    && mv cmdbuild.war $CATALINA_HOME/webapps/cmdbuild.war \
    && mv cmdbuild/* $CATALINA_HOME/webapps/cmdbuild/ \
    && chmod +x $CATALINA_HOME/webapps/cmdbuild/cmdbuild.sh \
    && chown -R tomcat:tomcat $CATALINA_HOME \
    && rm -rf /tmp/*

# Expõe a porta do Tomcat
EXPOSE 8080

# Define o usuário tomcat para rodar o contêiner
USER tomcat

# Define o ponto de entrada
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Comando padrão para iniciar o Tomcat
CMD ["catalina.sh", "run"]