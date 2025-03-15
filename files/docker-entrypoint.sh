#!/bin/bash
set -e

# Cria ou limpa o arquivo database.conf
cat /dev/null > $CATALINA_HOME/conf/cmdbuild/database.conf
echo "Configurando $CATALINA_HOME/conf/cmdbuild/database.conf"
{
    echo "db.url=jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
    echo "db.username=$POSTGRES_USER"
    echo "db.password=$POSTGRES_PASS"
    echo "db.admin.username=$POSTGRES_USER"
    echo "db.admin.password=$POSTGRES_PASS"
} >> $CATALINA_HOME/conf/cmdbuild/database.conf

# Aguarda o PostgreSQL ficar disponível
echo "Aguardando PostgreSQL em $POSTGRES_HOST:$POSTGRES_PORT..."
while ! timeout 1 bash -c "echo > /dev/tcp/$POSTGRES_HOST/$POSTGRES_PORT"; do
    >&2 echo "PostgreSQL não está disponível - aguardando..."
    sleep 5
done

# Inicializa o banco de dados (se necessário)
echo "Inicializando o banco de dados..."
{
    $CATALINA_HOME/webapps/cmdbuild/cmdbuild.sh dbconfig create empty.dump.xz -configfile $CATALINA_HOME/conf/cmdbuild/database.conf
} || {
    echo "Banco de dados já inicializado. Use 'dbconfig recreate' ou 'dbconfig drop' para reiniciar."
}

# Inicia o Tomcat
echo "Iniciando o Tomcat..."
exec $CATALINA_HOME/bin/catalina.sh run