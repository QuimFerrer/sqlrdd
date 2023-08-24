/*
* SQLRDD Test
* Copyright (c) 2003 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#include "sqlrdd.ch"
#include "myconn.ch"       // Personal credentials

#define RECORDS_IN_TEST                   1000
#define SQL_DBMS_NAME                       17
#define SQL_DBMS_VER                        18

REQUEST SQLRDD             // SQLRDD should be linked in
REQUEST SQLEX              // SQLRDD Extreme should be linked in

// REQUEST SR_ODBC            // Needed if you plan to connect with ODBC
// REQUEST SR_PGS             // Needed if you plan to use native connection to Postgres
REQUEST SR_MYSQL           // Needed if you plan to use native connection to MySQL
// REQUEST SR_ORACLE          // Needed if you plan to use native connection to Oracle
// REQUEST SR_FIREBIRD        // Needed if you plan to use native connection to Firebird

REQUEST DBFNTX
REQUEST DBFCDX
REQUEST DBFFPT
REQUEST DBFDBT


/*------------------------------------------------------------------------*/

PROCEDURE main()

   local nCnn, cTable
   local cRDD, cConnString
   local aFiles, oSql
   local aRows := {}

   RddSetDefault( "DBFCDX" )

   // Funciona indistintamente
   cConnString := "MySQL=localhost;UID=root;PWD="+__PWD__+";DTB="+__DB__
   cConnString := "Server=localhost; Port=3306; Database="+__DB__+"; Uid=root; Pwd="+__PWD__+";"

   SR_SETSQL2008NEWTYPES(.t.)
   SR_SetMininumVarchar2Size( 2 ) 
   SR_UseDeleteds(.f.)
   SR_SetlUseDBCatalogs( .T. )    // Utilizar indices de la BD

   ? "Test SQLRDD"
   ? ""
   ? "Connecting to database..."

   cRDD := "SQLRDD"
   nCnn := SR_AddConnection( CONNECT_MYSQL, cConnString )

   ? "Connected to        :", SR_GetConnectionInfo(, SQL_DBMS_NAME ), SR_GetConnectionInfo(, SQL_DBMS_VER )
   ? "RDD Version         :", SR_Version()
   ? "RDD in use          :", cRDD
   ? "ConnectionType      :", SR_GetConnection():nConnectionType

   CreaTabla( cRDD )

   ListaTablas()

   // Tablas creadas fuera del RDD fallan, error apertura !
   // Si queremos abrir una tabla con USE cTable VIA SQLRDD, que no haya sido creada con el RDD, 
   // tendremos que modificar la estructura y añadir un campo en dicha tabla
   // `sr_recno` BIGINT(20) NOT NULL AUTO_INCREMENT, UNIQUE INDEX `sr_recno` (`sr_recno`) USING BTREE
   // USE ( cTable ) VIA cRDD
   // BROWSE()

   //SqlQuery()

   RddQuery()

RETURN

/*------------------------------------------------------------------------*/

PROCEDURE CreaTabla( cRDD )
   
   local nArea 
   local cTable  := "customer"
   local aStruct := {;
      {"ID",   "N", 10,0 },;
      {"FIRST","C", 40,0 },;
      {"LAST", "C", 40,0 },;
      {"AGE",  "N", 10,0 } ; 
   }

   if ! SR_ExistTable( cTable ) 
      ? "Creating table      :", dbCreate( cTable, aStruct, cRDD )
   endif

   USE ( cTable ) EXCLUSIVE VIA ( cRDD )
   nArea := select()
   ( nArea )->( dbappend() )
   ( nArea )->FIRST   := "Mark"
   ( nArea )->LAST    := "Baley"
   ( nArea )->AGE     := 39
   ( nArea )->( dbgotop() )

   ? "Records      :", ( nArea )->( reccount() )

RETURN

/*------------------------------------------------------------------------*/

PROCEDURE ListaTablas()

   local aFiles, i

   aFiles := SR_ListTables("getex") 
   ? "Tablas de la BD     :", len(aFiles)

   ? "Lista de Tablas"
   for each i in aFiles 
      // Descartar tablas de sistema
      if ! left( i, 3 ) $ "SR_;TOP;SYS;DTP"
         ? i
      endif
   next 
   WAIT

RETURN

/*------------------------------------------------------------------------*/

PROCEDURE SqlQuery()

   local oSql, a, i
   local aRows := {}

   oSql:= SR_GetConnection()
   oSql:Exec("select * from customer",, .T., @aRows )
   ? oSql:GetAffectedRows()

   ? valtype(aRows), len(aRows)
   ? valtype(aRows[1])

   for each a in aRows 
      for each i in a
         ?? i
      next 
      ?
   next 
   WAIT

RETURN

/*------------------------------------------------------------------------*/

PROCEDURE RddQuery()

   dbUseArea( .F., "SQLRDD", "select * from customer", "customer" )
   ? customer->FIRST
   WAIT

   BROWSE()

RETURN

/*------------------------------------------------------------------------*/