#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <stdarg.h>
#include <errno.h>
#include <stdint.h>

#define MAX_QUERY_SIZE 1000
 
void error_fatal(char *format, ...); 
void print_table(MYSQL_RES *result);

const char* host = "localhost";
const char* user = "root";
const char* password = "christina";
const char* db = "mydb";
 
MYSQL* connection;
MYSQL_RES* result;
MYSQL_FIELD* field;
MYSQL_ROW row;

int main()
{
    connection = mysql_init(NULL);
    if(!mysql_real_connect(connection, host, user, password, db, 0, NULL,0))
        error_fatal("Greska pri konekciji: %s", mysql_error(connection));
        
    int exit=0;
    
    char lokacija[255], datum_pocetka[15], datum_kraja[15], query[MAX_QUERY_SIZE], ime[10], prezime[10];
    int broj_osoba, korisnikID, smestajid, kolicina; //ulogovan korisnik ima napunjen ovaj korisnikID
   
    //ovde staviti unesi sifru korisnika -- kao login korisnika  
    
    while(!exit){
        system("clear");
        printf("Izaberite opciju:\n");
        //opcije
        printf("[1] - Registracija korisnika\n");
        printf("[2] - Pretraga i rezervacija apartmana\n");
        printf("[3] - Uklanjanje korisnika\n");
        //printf("[4] - Rezervacija apartmana\n");
        printf("[5] - Otkazivanje rezervacije\n");
        printf("[6] - Ocenjivanje apartmana\n");
        printf("[7] - Uplacivanje apartmana\n");
        printf("[8] - Izlaz iz programa\n");
        
        //kraj opcija
        int option;
        scanf("%d", &option);
        
        switch(option){
            case 1: //Registracija korisnika
            
            sprintf(query, "select max(korisnikID) from Korisnik");
            if(mysql_query(connection, query))
                error_fatal("Upit 5: %s\n", mysql_error(connection));
            
            result = mysql_store_result(connection); 
            
            while((row = mysql_fetch_row(result))!=0)
                {                       
                    korisnikID = row[0] ? atoi(row[0]) : 0;
                }
            korisnikID++;
            
        sprintf(query, "insert into Korisnik values (%d, 'Petar', 'Micic', DATE('2003-12-31'))", korisnikID);
            
             if(mysql_query(connection, query))
                error_fatal("Upit 5: %s\n", mysql_error(connection));
           //result = mysql_store_result(connection); 
            //print_table(result);
            
            
            
            //mysql_free_result(result);
            
            break;
            case 2: //Uklanjanje korisnika
            //prvo pregled svih korisnika 
            sprintf(query, "select korisnikID, imeKorisnika, prezimeKorisnika, datumRodjenja from Korisnik");
            
            if(mysql_query(connection, query))
                error_fatal("Upit 5: %s\n", mysql_error(connection));
            
            result = mysql_store_result(connection);
            
            getchar();
            print_table(result);
            
            printf("Aasd\n");
            scanf("%s", datum_pocetka);
            getchar();
            
            printf("Uneti ID korisnika za uklanjanje:\n");
            int id;
            
            scanf("%d", &id);
            
            //sprintf(query, "delete from Korisnik where korisnikID=%d", id);
            printf("%s", query);
            
            if(mysql_query(connection, query)) //vraca NULL ako radi
                error_fatal("Upit 5: %s\n", mysql_error(connection));
            else
                printf("Korisnik je uspeno uklonjen\n");
                
            
            break;
            case 3: //Pretraga apartmana, --ovo ce da ide u dva upita apartmani i komentari apartmana 
               
            printf("Unesi lokaciju:");    
            scanf("%s", lokacija);
            getchar();
            
            printf("Unesi broj osoba:");
            scanf("%d", &broj_osoba);
            getchar();
       /*     
            printf("Unesi datum pocetka iznajmljivanja:");
            scanf("%s", datum_pocetka);
            
            getchar();
           
            
            printf("Unesi datum kraja iznajmljivanja:");
            scanf("%s", datum_kraja);*/
            strcpy(datum_pocetka,"28.06.2019");
            strcpy(datum_kraja,"30.06.2019");
            
            getchar();
            
            char *temp = "select s.smestajID,brojSoba,tipSmestaja,brojKreveta,imaKlimu,imaPogled,imaBalkon,imaPrivatnoKupatilo,imaFlatScreenTv,vs.vlasnistvoSmestajaID,cenaNoci \
                            from Smestaj s join VlasnistvoSmestaja vs \
	                       on vs.vlasnistvoSmestajaID=s.vlasnistvoSmestajaID \
                            join Lokacija l \
                            	on l.idLokacija=vs.LokacijaID \
                            join Iznajmljivanje i \
                            	on i.smestajID=s.smestajID";
            
            
            sprintf(query, "select * from Iznajmljivanje where brojDana=%d", broj_osoba);
            printf("%d", strlen(query));
                                
          /*  sprintf("where l.naziv like '%%s%' and s.brojKreveta >= %d"
                            and date('%s') not between datumPocetka and datumKraja and date('%s') not between datumPocetka and datumKraja;

            
            */printf("%d", strlen(query));
            
            if(mysql_query(connection, query))
                error_fatal("Opcija 3: Neuspeli upit!");
                
            result = mysql_use_result(connection);
            
            
            //ispis apartmana
            print_table(result); // da li u okviru print_table oslobadjati result ?
            
          /*  printf("Uneti sifru smestaja za iznajmljivanje\n");
            int aptid;
            scanf("%d", &aptid);
            
            //rezervacija 
            
            sprintf(query, "insert into Iznajmljivanje values \
                (%d, %d , date('%s'), date('%s'), %d , now())", aptid, korisnikID, datum_pocetka, datum_kraja, 156);
                
            if(!mysql_query(connection, query))
                error_fatal("Opcija 3: Neuspesno iznajmljivanje\n");
                */
            mysql_free_result(result);
            break;
             /*  case 4: //Rezervacija apartmana
                
                
                
                
            break;*/
            case 5: //Otkazivanje rezervacije
            //prvo pregled svih aktivnih rezervacija 

            sprintf(query, "select * from Iznajmljivanje");
            
            if(mysql_query(connection, query))//vraca 1 ako je uspesno 
                error_fatal("Opcija 3: Neuspesno iznajmljivanje\n");
                
            result = mysql_store_result(connection); 
            
            print_table(result);
            //pa otkazivanje rezervacije, uklanjanje iz tabele rezervacija 
            
            break;
            case 6: //Ocenjivanje smestaja
            
            //izlistati osnovne informacije o apartmanima i pored dopisati komentari
            // neki join svega toga
            
            
            //uneti sifru 
            
            printf("Uneti id smestaja za ocenjivanje:\n");
            scanf("%d", &smestajid);
            
            sprintf(query, "select * from Smestaj where smestajID=%d", smestajid);
            
            if(!mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
            
            
          //  print_table(result);
            
            //ovde izlistati u fazonu ocenjuje se smestaj [] []
            
            
            
            break;
            
            //uplacivanje apartmana:
            case 7: 
            
            printf("Uneti id smestaja za uplacivanje:\n");
            scanf("%d", &smestajid);
            printf("Uneti iznos za uplatu:\n");
            scanf("%d", &kolicina);
            
            
            sprintf(query, "update Placanje \
                            set uplaceno = %d \
                            where korisnikID=%d and smestajID=%d", kolicina, korisnikID, smestajid);
        
            if(mysql_query(connection, query))
                error_fatal("Opcija 7: Neuspesno uplacivanje racuna\n");
                

            break;
            
            case 8:
                printf("Izlazak iz aplikacije\n");
                exit = 1;
            break;
            
            default:
                printf("Izabrana opcija ne postoji!");
        }
        
        
    }


    return 0;
}


void error_fatal(char* format, ...)
{
  va_list arguments;
 
  va_start(arguments, format);
  vfprintf(stderr, format, arguments);
  va_end(arguments);
 
  exit(EXIT_FAILURE);
}

//FIXME u slucaju da je prazna tabela da ne ispisuje nazive kolona :) 
void print_table(MYSQL_RES *result){
    MYSQL_ROW row;
    int num_fields;
    MYSQL_FIELD* field;
    num_fields = mysql_num_fields(result);
    field = mysql_fetch_fields(result);
    printf("|");
    int charcount = 1;
    for(int i=0;i<num_fields;i++){
        printf(" %s |", field[i].name);
        charcount += strlen(field[i].name) + 3;
        
    }
    printf("\n");
    
     for(int i=0;i<charcount;i++){
        printf("-");
    }   

    printf("\n");
    
    
        while((row=mysql_fetch_row(result))!=NULL){
            printf("|");
            
            for(int i=0;i<num_fields;i++){
                printf("[%s] ", row[i] ? row[i] : "NULL");
            }
            printf("\n");
        }
            
    
    
        mysql_free_result(result);
}
