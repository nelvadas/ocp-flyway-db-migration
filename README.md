# Flyway Database Migraiton in Openshift Demo

oc new-project ocp-flyway-db-migration
# Create a demo Postgres db with default credentials postgres/postgres
oc new-app jbossdevguidebook/beosbank_posgres_db_europa:latest  --name=beosbank-posgres-db-europa 
