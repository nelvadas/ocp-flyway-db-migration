# Flyway Database Migraiton in Openshift Demo

oc new-project ocp-flyway-db-migration
oc new-app jbossdevguidebook/beosbank_posgres_db_europa:latest  --name=beosbank-posgres-db-europa 
 oc create  cm sql-configmap --from-file=./sql 
