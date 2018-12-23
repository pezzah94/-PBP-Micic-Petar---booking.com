#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <stdarg.h>
#include <errno.h>
#include <stdint.h>
 
#define MAX_QUERY_SIZE 2024

/*USERTYPE:
 * 0 - Student
 * 1 - Zaposlen
 * 2 - Lice
 */

void error_fatal(char *format, ...); 
void print_table(MYSQL_RES *result);
int user_identification(const char *user, int *userID, int *usertype);
void show_user_info(const char *user, int userID, int usertype);

void show_for_student(const char* lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja);
void show_for_zaposlen(const char* lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja);
void show_for_lice(const char* lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja);

void show_near_objects(const char *lokacija);


const char* host = "localhost";
const char* userb = "root";
const char* password = "christina";
const char* db = "mydb";
  
int userID;//ime logovanog korisnika 
 	//id logovanog korisnika
char user[15];
int usertype;

MYSQL* connection;
MYSQL_RES* result;
MYSQL_FIELD* field;
MYSQL_ROW row;
 
int main()
{
    
    connection = mysql_init(NULL);
    if(!mysql_real_connect(connection, host, userb, password, db, 0, NULL,0))
        error_fatal("Greska pri konekciji: %s", mysql_error(connection));
    
    int exit=0;
     
    char lokacija[255], datum_pocetka[15], datum_kraja[15], query[MAX_QUERY_SIZE], ime[10], prezime[10], datum_rodjenja[15], naziv_fakulteta[15], indeks[11];
    int broj_osoba, korisnikID, smestajid, uplaceno; //ulogovan korisnik ima napunjen ovaj korisnikID
    
    printf("Login: Uneti korisnicko ime:\n");
    scanf("%s", user);
    
    user_identification(user, &userID, &usertype);
   
   
    show_user_info(user, userID, usertype);
   
    
    
    //ovde staviti unesi sifru korisnika -- kao login korisnika  
     
    while(!exit){
        system("clear");
        printf("Izaberite opciju:\n");
        //opcije
        printf("[1] - Registracija korisnika\n");//samo ako je admin radi, inace nedozvoljena operacija
		
        printf("[2] - Uklanjanje korisnika\n");
        printf("[3] - Pretraga i rezervacija apartmana\n");
        printf("[4] - Otkazivanje rezervacije\n");
        printf("[5] - Ocenjivanje apartmana\n");
        printf("[6] - Uplacivanje apartmana\n");
        
        printf("[7] - Pregled najblizih objekata\n");
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
            
            
            printf("Unesi ime korisnika:\n");
            scanf("%s", ime);
            getchar();
            printf("Unesi prezime korisnika\n");
            scanf("%s", prezime);
            getchar();
            printf("Unesi datum rodjenja [YYYY-MM-DD]:\n");
            scanf("%s", datum_rodjenja);
            getchar();
            
            
            sprintf(query, "insert into Korisnik values (%d, '%s', '%s', DATE('%s'), 'not active', 0)", korisnikID, ime, prezime, datum_rodjenja);
            if(mysql_query(connection, query))
                error_fatal("Upit 5: %s\n", mysql_error(connection));
            
            printf("[1] - Unos studenta\n");
			printf("[2] - Unos fizickog lica\n");
			printf("[3] - Unos zaposlenog osoblja\n");
			
			
			int opc;
			scanf("%d", &opc);
			
			// indeks i naziv fakulteta
			if(opc==1){
                printf("Unesi naziv fakulteta:\n");
                scanf("%s", naziv_fakulteta);
                getchar();
                printf("Unesi indeks studenta:\n");
                scanf("%s", indeks);
                getchar();
                sprintf(query, "insert into Student values (%d, '%s', '%s')", korisnikID, indeks, naziv_fakulteta);
            } else if(opc==2){
                sprintf(query, "insert into Lice values (%d)", korisnikID);
            }else if(opc==3){
                printf("Unesi zanimanje:\n");
                scanf("%s", naziv_fakulteta);
                getchar();
                printf("Unesi naziv firme:\n");
                scanf("%s", indeks);
                getchar();
                sprintf(query, "insert into Zaposlen values (%d, '%s', '%s')", korisnikID, indeks, naziv_fakulteta);
                
            }else {
                
            }
             if(mysql_query(connection, query))
                error_fatal("Case 1: %s\n", mysql_error(connection));
             
            //mysql_free_result(result);
             
            break;
            case 2: //Uklanjanje korisnika  
            //prvo pregled svih korisnika 
            sprintf(query, "select korisnikID, imeKorisnika, prezimeKorisnika, datumRodjenja,status, booked from Korisnik");
             
            if(mysql_query(connection, query))
                error_fatal("Upit 5: %s\n", mysql_error(connection));
             
            result = mysql_store_result(connection);
             
            getchar();
            print_table(result);
             
            
            printf("Uneti ID korisnika za uklanjanje:\n");
            int id;
             
            scanf("%d", &id);
             
            sprintf(query, "delete from Korisnik where korisnikID=%d", id);
           // printf("%s", query);
             
            if(mysql_query(connection, query)) //vraca NULL ako radi
                error_fatal("Upit 5: %s\n", mysql_error(connection));
            else
                printf("Korisnik je uspeno uklonjen\n");
                 
             
            break;
			
            case 3: //Pretraga apartmana, --ovo ce da ide u dva upita apartmani i komentari apartmana 
                    //prikaz ocena za 
					//konkretno te apartmane 
            printf("Unesi lokaciju:");    
            scanf("%s", lokacija);
            getchar();
             
            printf("Unesi broj osoba:");
            scanf("%d", &broj_osoba);
            
            printf("Unesi datum pocetka iznajmljivanja:");
            scanf("%s", datum_pocetka);
             
            getchar();
            
            printf("Unesi datum kraja iznajmljivanja:");
            scanf("%s", datum_kraja);
           
            getchar();
             
            //prikaz za studenta, zaposlenog lice 
            printf("%d", usertype);
            switch(usertype){
                case 0: show_for_student(lokacija,broj_osoba,datum_pocetka,datum_kraja);break;
                case 1: show_for_student(lokacija,broj_osoba,datum_pocetka,datum_kraja);break;
                case 2: show_for_student(lokacija,broj_osoba,datum_pocetka,datum_kraja);break;
               
            }
            
            
            /*sprintf(query, "select s.smestajID,brojSoba,tipSmestaja,brojKreveta,imaKlimu,imaPogled \
							,imaBalkon,imaPrivatnoKupatilo,imaFlatScreenTv,vs.vlasnistvoSmestajaID,cenaNoci \
							from Smestaj s join VlasnistvoSmestaja vs \
								on vs.vlasnistvoSmestajaID=s.vlasnistvoSmestajaID \
							join Lokacija l \
								on l.idLokacija=vs.LokacijaID \
							join Iznajmljivanje i \
								on i.smestajID=s.smestajID \
							where l.naziv like '%%%s%%' and s.brojKreveta >= %d \
							and date('%s') not between datumPocetka and datumKraja \
							and date('%s') not between datumPocetka and datumKraja", lokacija, broj_osoba, datum_pocetka, datum_kraja);

            printf("%s", query);
            
            if(mysql_query(connection, query))
                error_fatal("Opcija 3: Neuspeli upit!");
                 
            result = mysql_use_result(connection);
             
             
            //ispis apartmana
            print_table(result); // da li u okviru print_table oslobadjati result ?
			
			// unosi se sifra iznajmljivanja apartmana
			*/
			printf("Unesi sifru smestaja za iznajmljivanje:\n");
			scanf("%d", &smestajid);
			
			sprintf(query, "insert into Iznajmljivanje values \
			(%d, %d , date('%s'), date('%s'),  0 ,  now(), NULL, 0, NULL);", userID,  smestajid, datum_pocetka, datum_kraja);
            
            //printf("%s", query);
			
            if(mysql_query(connection, query))
                error_fatal("Opcija 3: Neuspeli upit!"); 
			else 
				printf("Uspesno iznajmljivanje apartmana %d", smestajid);
			
			
            break;
            
			
            case 4: // otkazivanje rezervacije samo na osnovu userID
			
			sprintf(query, "select smestajID, datumPocetka, datumKraja, brojDana,  vremeIznajmljivanja, datumUplate, ukupanIznos, uplaceno \
from Iznajmljivanje where korisnikID=%d", userID);
            
            if(mysql_query(connection, query))//vraca 1 ako je uspesno 
                error_fatal("Opcija 3: Neuspesno iznajmljivanje\n");
                 
            result = mysql_store_result(connection); 
             
            print_table(result);
            //pa otkazivanje rezervacije, uklanjanje iz tabele rezervacija 
            printf("Unesi id apartmana za otkazivanje\n");
			scanf("%d", &smestajid);
			
			sprintf(query, "delete from Iznajmljivanje where korisnikID=%d and smestajID=%d", userID, smestajid);
			if(mysql_query(connection, query))//vraca 1 ako je uspesno 
                error_fatal("Opcija 3: Neuspesno iznajmljivanje\n");
			else
				printf("Rezervacija je uspesno otkazana.\n");
			
            break;
            case 5: //ocenjivanje apartmana
			
			printf("Review apartmana\n");
			 
			sprintf(query, "select k.imeKorisnika,k.korisnikID,smestajID,cistoca,lokacija,osoblje,usluge,komfort,datumOcene,komentar \
             from OceneSmestaja os \
            join Korisnik k \
            on os.KorisnikID=k.KorisnikID \
            ");	
            if(mysql_query(connection, query))//vraca 1 ako je uspesno 
                error_fatal("Opcija 3: Neuspesno iznajmljivanje\n");
            result = mysql_store_result(connection); 
            print_table(result); 
            
			printf("Uneti id smestaja za ocenjivanje:\n");
            scanf("%d", &smestajid);
            printf("Uneti ocene smestaja:\n");
            int marks[5];
            for(int i=0;i<5;i++)
                scanf("%d", &marks[i]);
            getchar();
            
            char * line = malloc(256*sizeof(char));
            if(!line)
                error_fatal("Malloc error!");
            size_t len=0;
            getline(&line, &len, stdin);
            line[strlen(line)-1]=0;
            
            
            sprintf(query, "insert into OceneSmestaja values \
(%d, %d, %d, %d, %d, %d, %d, now(), '%s');",userID, smestajid, marks[0], marks[1], marks[2], marks[3], marks[4], line );	
            
             
			
             
            if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
             
             
            print_table(result);
             
            
            break;
             
            
            case 6: //uplacivanje apartmana:
			
			//pregled svih iznajmljenih apartmana samo na osnovu userID
			printf("Pregled svih uplata:\n");
			
			sprintf(query, "select smestajID, datumPocetka, datumKraja, brojDana,  vremeIznajmljivanja, datumUplate, ukupanIznos, uplaceno \
from Iznajmljivanje where korisnikID=%d", userID);
			
			if(mysql_query(connection, query))
			    error_fatal("Opcija 7: Neuspesno uplacivanje racuna\n");
			
			result = mysql_use_result(connection);
             
            
            print_table(result);
			
			printf("Uneti id smestaja za uplacivanje:\n");
			scanf("%d", &smestajid);
			printf("Uneti iznos za uplatu:\n");
			scanf("%d", &uplaceno);
 
 
			sprintf(query, "update Iznajmljivanje set uplaceno = %d where korisnikID=%d and smestajID=%d", uplaceno, userID, smestajid);

            if(mysql_query(connection, query))
                error_fatal("Opcija 7: Neuspesno uplacivanje racuna\n");
            else 
				printf("Uplata je uspesno izvrsena za smestaj %d", smestajid);
 
            break;
            case 7:
                //izlistavam prvo hotele na osnovu lokacije
                printf("Unesi lokaciju:\n");
                scanf("%s", lokacija);
                
                sprintf(query, "select vs.vlasnistvoSmestajaID, vs.naziv \
from VlasnistvoSmestaja vs \
join Lokacija l \
	on vs.LokacijaID=l.idLokacija \
where l.drzava like '%%%s%%'", lokacija);
                
                
                if(mysql_query(connection, query))
			    error_fatal("Opcija 7: Neuspesno uplacivanje racuna\n");
			
                result = mysql_use_result(connection);
                
                print_table(result);
                //2. unosi se id hotela 
                
                printf("Unesi id hotela:\n");
                scanf("%d", &smestajid);
                
                
                
                
                //3. izlistavaju se najblizi objekti
                sprintf(query, " select vs.naziv, concat('U blizini ', vs.naziv, 'nalazi se ', \
                        o.naziv, ' na udaljenosti ', coalesce(concat(d.opis, '.'), concat(d.km, \ 'kilometara.'))) \
 from VlasnistvoSmestaja vs join Distanca d \
	on vs.vlasnistvoSmestajaID=d.vlasnistvoSmestajaID \
join Objekti o \
	on d.objektiID=o.objektiID \
where vs.vlasnistvoSmestajaID=%d", smestajid);
                
                
                if(mysql_query(connection, query))
                    error_fatal("Opcija 7: Neuspesno uplacivanje racuna\n");
			
                result = mysql_use_result(connection);
                
                print_table(result);
                
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


int user_identification(const char *user, int *userID, int *usertype){
    
    // pretraga baze ako je admin sa posebnim IDjem ili korisnik sa nekim IDjem
    char query[MAX_QUERY_SIZE];
    //printf("[[%s]]", user);
    sprintf(query, "select k.korisnikID as Korisnik, k.imeKorisnika as Ime, \
(case \
	when s.korisnikID is not null then 0 \
    when z.zaposlenID is not null then 1 \
    when l.liceID is not null then 2 \
end) as Tip \
from Korisnik k \
left outer join Student s \
	on k.korisnikID=s.KorisnikID \
left outer join Zaposlen z \
	on k.KorisnikID=z.zaposlenID \
left outer join Lice l \
	on l.liceID=k.korisnikID \
where k.imeKorisnika like '%%%s%%'", user);
    
    
    
    //printf("%s", query);
    MYSQL_RES *result;
    MYSQL_ROW row;
    if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
        
    result = mysql_store_result(connection); 
    
    if(mysql_num_rows(result)==0)
        printf("Korisnik nije pronadjen u bazi!");
    
    row = mysql_fetch_row(result);
    *userID = atoi(row[0]);
    
    *usertype = atoi(row[2]);
   // printf("[%d]", *usertype);
   
    mysql_free_result(result);
}

void show_user_info(const char *user, int userID, int usertype){
    
    switch(usertype){
        case 0: printf("|Student");break;
        case 1: printf("|Zaposlen");break;
        case 2: printf("|Fizicko lice");break;
        
    }
    printf("|USER:%s|ID:%d|\n", user? user: "NULL", userID);
    
}


void show_for_student(const char *lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja){
    char query[MAX_QUERY_SIZE];
    
    sprintf(query, "SELECT s.smestajid, \
       brojsoba,ovs.imaWifi, \
       tipsmestaja, \
       brojkreveta, \
       imaklimu, \
       imapogled, \
       imabalkon, \
       imaprivatnokupatilo, \
       imaflatscreentv, \
       vs.vlasnistvosmestajaid, \
       cenanoci \
FROM   Smestaj s \
       JOIN VlasnistvoSmestaja vs \
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid \
       JOIN Lokacija l \
         ON l.idlokacija = vs.lokacijaid \
       JOIN OpisVlasnistvaSmestaja ovs \
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID \
       left outer JOIN Iznajmljivanje i \
         ON i.smestajid = s.smestajid \
		WHERE  l.drzava LIKE '%%%s%%' \
       AND s.brojkreveta >= %d \
      and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and \ coalesce(i.datumKraja, \
      date('1900-01-02')) \
and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, \
date('1900-01-02')) \
group by s.smestajID \
order by s.cenaNoci asc, ovs.imaWifi desc, ovs.noPrepayment desc, s.imaFlatScreenTv desc", lokacija, broj_osoba, datum_pocetka, datum_kraja);
    
    
    MYSQL_RES *result;
    MYSQL_ROW row;
    if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
    
    result = mysql_store_result(connection);
    print_table(result);
    mysql_free_result(result);
}
void show_for_zaposlen(const char* lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja){
    char query[MAX_QUERY_SIZE];
    
     sprintf(query, "SELECT s.smestajid, \
       brojsoba,ovs.imaWifi, \
       tipsmestaja, \
       brojkreveta, \
       imaklimu, \
       imapogled, \
       imabalkon, \
       imaprivatnokupatilo, \
       imaflatscreentv, \
       vs.vlasnistvosmestajaid, \
       cenanoci \
FROM   Smestaj s \
       JOIN VlasnistvoSmestaja vs \
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid \
       JOIN Lokacija l \
         ON l.idlokacija = vs.lokacijaid \
       JOIN OpisVlasnistvaSmestaja ovs \
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID \
       left outer JOIN Iznajmljivanje i \
         ON i.smestajid = s.smestajid \
		WHERE  l.drzava LIKE '%%%s%%' \
       AND s.brojkreveta >= %d \
      and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and \ coalesce(i.datumKraja, \
      date('1900-01-02')) \
and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, \
date('1900-01-02')) \
group by s.smestajID \
 order by s.cenaNoci asc,ovs.imaWifi desc, ovs.imaRoomService, ovs.imaParking desc, \
 ovs.imaSpa desc, ovs.ukljucenDorucak", lokacija, broj_osoba, datum_pocetka, datum_kraja);
    
    
    MYSQL_RES *result;
    MYSQL_ROW row;
    if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
    
    result = mysql_store_result(connection);
    print_table(result);
    mysql_free_result(result);
    
}
void show_for_lice(const char* lokacija, int broj_osoba, const char *datum_pocetka, const char *datum_kraja){
    char query[MAX_QUERY_SIZE];
    
    sprintf(query, "SELECT s.smestajid, \
       brojsoba,ovs.imaWifi, \
       tipsmestaja, \
       brojkreveta, \
       imaklimu, \
       imapogled, \
       imabalkon, \
       imaprivatnokupatilo, \
       imaflatscreentv, \
       vs.vlasnistvosmestajaid, \
       cenanoci \
FROM   Smestaj s \
       JOIN VlasnistvoSmestaja vs \
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid \
       JOIN Lokacija l \
         ON l.idlokacija = vs.lokacijaid \
       JOIN OpisVlasnistvaSmestaja ovs \
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID \
       left outer JOIN Iznajmljivanje i \
         ON i.smestajid = s.smestajid \
		WHERE  l.drzava LIKE '%%%s%%' \
       AND s.brojkreveta >= %d \
      and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and \ coalesce(i.datumKraja, \
      date('1900-01-02')) \
and date('%s') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, \
date('1900-01-02')) \
group by s.smestajID \
 order by s.cenaNoci asc, ovs.ukljucenDorucak", lokacija, broj_osoba, datum_pocetka, datum_kraja);
    
    
    MYSQL_RES *result;
    MYSQL_ROW row;
    if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
    
    result = mysql_store_result(connection);
    print_table(result);
    
    mysql_free_result(result);
}


void show_near_objects(const char *lokacija){
    char query[MAX_QUERY_SIZE];
    
    //sprintf(query, "", lokacija, broj_osoba, datum_pocetka, datum_kraja);
    
    
    MYSQL_RES *result;
    MYSQL_ROW row;
    if(mysql_query(connection, query))
                error_fatal("Opcija 6: Neuspesno\n");
    
    result = mysql_store_result(connection);
    print_table(result);
    mysql_free_result(result);
}


