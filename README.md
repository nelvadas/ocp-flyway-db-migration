# Flyway Database Migration in Openshift Demo

## Introduction

## Starting the Database
Connect on minishift cluster
``` oc login -u developer -p developer ``

Create a new project 

```oc new-project ocp-flyway-db-migration```


Connect as admin rant the anyuid scc to the default service acccount in the ocp-flyway-db-migration project

```oc adm policy add-scc-to-user anyuid -z default```


Create the postgres DB application in the ocp-flyway-db-migration project
```
 oc new-app --docker-image=jbossdevguidebook/beosbank_posgres_db_europa:latest --name=beosbank-postgres-db-europa

--> Found Docker image dafaf18 (7 months old) from Docker Hub for "jbossdevguidebook/beosbank_posgres_db_europa:latest"
    * An image stream will be created as "beosbank-postgres-db-europa:latest" that will track this image
    * This image will be deployed in deployment config "beosbank-postgres-db-europa"
    * Port 5432/tcp will be load balanced by service "beosbank-postgres-db-europa"
      * Other containers can access this service through the hostname "beosbank-postgres-db-europa"
    * This image declares volumes and will default to use non-persistent, host-local storage.
      You can add persistent volumes later by running 'volume dc/beosbank-postgres-db-europa --add ...'
    * WARNING: Image "jbossdevguidebook/beosbank_posgres_db_europa:latest" runs as the 'root' user which may not be permitted by your cluster administrator

--> Creating resources ...
    imagestream "beosbank-postgres-db-europa" created
    deploymentconfig "beosbank-postgres-db-europa" created
    service "beosbank-postgres-db-europa" created
--> Success
    Run 'oc status' to view your app.

```
The application starts and you have a postgres pod

![Beosbank Database pod](https://github.com/nelvadas/ocp-flyway-db-migration/blob/master/beosbank-db-pod.png)

Check the database content
* List the pods in the current project
```
$ oc get pods
NAME                                 READY     STATUS    RESTARTS   AGE
beosbank-posgres-db-europa-1-p16bx   1/1       Running   1          22h
```

* Connect to the running db pod using oc rsh command 
```
ocp-flyway-db-migration$ oc rsh beosbank-posgres-db-europa-1-p16bx
# psql -U postgres
psql (9.6.2)
Type "help" for help.
```
* Check the database list with \l
```
postgres=# \l
                                    List of databases
      Name       |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------------+----------+----------+------------+------------+-----------------------
 beosbank-europa | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres        | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |          |            |            | postgres=CTc/postgres
 template1       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |          |            |            | postgres=CTc/postgres
(4 rows)
```
* Connect to the beosbank db \connect   and list relations \d

```
postgres=# \connect beosbank-europa
You are now connected to database "beosbank-europa" as user "postgres".
beosbank-europa=#

beosbank-europa=# \d
             List of relations
 Schema |       Name       | Type  | Owner
--------+------------------+-------+-------
 public | eu_customer      | table | root
 public | eu_moneytransfer | table | root
(2 rows)
```


* display the content of the eu_customer table

<pre><code>
beosbank-europa=# select * from eu_customer;
 id |   city    | country  |      street       |  zip   | birthdate  | firstname  | lastname
----+-----------+----------+-------------------+--------+------------+------------+-----------
  1 | Berlin    | Germany  | brand burgStrasse | 10115  | 1985-06-20 | Yanick     | Modjo
  2 | Bologna   | Italy    | place Venice      | 40100  | 1984-11-21 | Mirabeau   | Luc
  3 | Paris     | France   | Bld DeGaule       | 75001  | 2000-02-07 | Noe        | Nono
  4 | Chatillon | France   | Avenue JFK        | 55     | 1984-02-19 | Landry     | Kouam
  5 | Douala    | Cameroon | bld Liberte       | 1020   | 1996-04-21 | Ghislain   | Kamga
  6 | Yaounde   | Cameroon | Hypodrome         | 1400   | 1983-11-18 | Nathan     | Brice
  7 | Bruxelles | Belgium  | rue Van Gogh      | 1000   | 1980-09-06 | Yohan      | Pieter
 <b> 8 | London    | UK       | street Lavoisier  | 208    | 1990-01-01 | John       | Doe</b>
  9 | Bamako    | Mali     | Rue Modibo Keita  | 30     | 1979-05-17 | Mohamed    | Diallo
 10 | Cracovie  | Pologne  | Avenue Vienne     | 434    | 1983-05-17 | Souleymann | Njifenjou
 11 | Chennai   | India    | Gandhi street     | 600001 | 1990-02-13 | Anusha     | Mandalapu
 12 | Sao Polo  | Brasil   | samba bld         | 69400  | 1994-02-13 | Adriana    | Pinto
(12 rows)
</code></pre>



```git clone https://github.com/nelvadas/ocp-flyway-db-migration.git```

```cd ocp-flyway-db-migration```

``` oc create  cm sql-configmap --from-file=./sql```


## Containerizing Flyway SQL updates 

```
$docker build -t --no-cache  jbossdevguidebook/flyway:v1.0.4-rhdblog .

...

2018-01-07 13:48:43 (298 KB/s) - 'flyway-commandline-4.2.0.tar.gz' saved [13583481/13583481]

 ---> 095befbd2450
Removing intermediate container 8496d11bf4ae
Step 8/9 : VOLUME /var/flyway/data
 ---> Running in d0e012ece342
 ---> 4b81dfff398b
Removing intermediate container d0e012ece342
Step 9/9 : ENTRYPOINT cp -f /var/flyway/data/\*.sql  $FLYWAY_HOME/sql/ &&             $FLYWAY_HOME/flyway  baseline migrate info  -user=${DB_USER} -password=${DB_PASSWORD} -url=${DB_URL}
 ---> Running in ff2431eb1c26
 ---> 0a3721ff4863
Removing intermediate container ff2431eb1c26
Successfully built 0a3721ff4863
Successfully tagged jbossdevguidebook/flyway:v1.0.4-rhdblog

```

## Kubernetes in action

Move to the sql folder and create a 

```$ cd ocp-flyway-db-migration/sql 
   $ ls -rtl
total 32
-rw-r--r--  1 enonowog  staff  47 Oct 20 18:48 V2.3__UpdateZip.sql
-rw-r--r--  1 enonowog  staff  63 Oct 20 18:48 V2.2__UpdateCountry2.sql
-rw-r--r--  1 enonowog  staff  58 Jan  7 15:36 V1.1__UpdateCountry.sql
-rw-r--r--  1 enonowog  staff  84 Jan  7 15:42 V3.0__UpdateStreet.sql
```
Theses file describe 04 flyways modifications to be applied on the database from V1.1, V2.2, v2.3 to V3.0

```
$ cd ocp-flyway-db-migration/sql
$oc create cm sql-configmap --from-file=.
configmap "sql-configmap" created
```


Create a Job to update the database
```
$ oc create -f https://raw.githubusercontent.com/nelvadas/ocp-flyway-db-migration/master/beosbank-flyway-job.yaml 
```

Check the Jobs
```
$ oc get jobs
NAME                     DESIRED   SUCCESSFUL   AGE
beosbank-dbupdater-job   1         1            2d
```

Check the pods

```
$ oc get pods
NAME                                 READY     STATUS      RESTARTS   AGE
beosbank-dbupdater-job-wzk9q         0/1       Completed   0          2d
beosbank-posgres-db-europa-1-p16bx   1/1       Running     2          6d
```

The  job instance completed successfully 

```

$ oc logs beosbank-dbupdater-job-wzk9q
Flyway 4.2.0 by Boxfuse
Database: jdbc:postgresql://beosbank-posgres-db-europa/beosbank-europa (PostgreSQL 9.6)
Creating Metadata table: "public"."schema_version"
Successfully baselined schema with version: 1
Successfully validated 5 migrations (execution time 00:00.014s)
Current version of schema "public": 1
Migrating schema "public" to version 1.1 - UpdateCountry
Migrating schema "public" to version 2.2 - UpdateCountry2
Migrating schema "public" to version 2.3 - UpdateZip
Migrating schema "public" to version 3.0 - UpdateStreet
Successfully applied 4 migrations to schema "public" (execution time 00:00.046s).
+---------+-----------------------+---------------------+---------+
| Version | Description           | Installed on        | State   |
+---------+-----------------------+---------------------+---------+
| 1       | << Flyway Baseline >> | 2018-01-05 04:35:16 | Baselin |
| 1.1     | UpdateCountry         | 2018-01-05 04:35:16 | Success |
| 2.2     | UpdateCountry2        | 2018-01-05 04:35:16 | Success |
| 2.3     | UpdateZip             | 2018-01-05 04:35:16 | Success |
| 3.0     | UpdateStreet          | 2018-01-05 04:35:16 | Success |
+---------+-----------------------+---------------------+---------+
```

The database have been updated accordingly

<pre><code>
beosbank-europa=# select * from eu_customer;
 id |    city     |     country      |      street       |  zip   | birthdate  |firstname  | lastname
----+-------------+------------------+-------------------+--------+------------+------------+-----------
  1 | Berlin      | Germany          | brand burgStrasse | 10115  | 1985-06-20 | Yanick     | Modjo
  2 | Bologna     | Italy            | place Venice      | 40100  | 1984-11-21 | Mirabeau   | Luc
  3 | Paris       | France           | Bld DeGaule       | 75001  | 2000-02-07 | Noe        | Nono
  4 | Chatillon   | France           | Avenue JFK        | 55     | 1984-02-19 | Landry     | Kouam
  5 | Douala      | Cameroon         | bld Liberte       | 1020   | 1996-04-21 | Ghislain   | Kamga
  6 | Yaounde     | Cameroon         | Hypodrome         | 1400   | 1983-11-18 | Nathan     | Brice
  7 | Bruxelles   | Belgium          | rue Van Gogh      | 1000   | 1980-09-06 | Yohan      | Pieter
  9 | Bamako      | Mali             | Rue Modibo Keita  | 30     | 1979-05-17 | Mohamed    | Diallo
 10 | Cracovie    | Pologne          | Avenue Vienne     | 434    | 1983-05-17 |Souleymann | Njifenjou
 <b>11 | Chennai     | Red Hat Training | Gandhi street     | 600001 | 1990-02-13 | Anusha     | Mandalapu</b>
<b> 12 | Sao Polo    | Open Source      | samba bld         | 75020  | 1994-02-13 | Adriana    | Pinto</b>
 <b> 8 | Farnborough | UK               | 200 Fowler Avenue | 208    | 1990-01-01 |John       | Doe</b>
(12 rows)
```

-------
