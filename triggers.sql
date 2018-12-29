-- trigger 1:
-- iznajmljivanje cuva info o tekucim rezervacijama, kada se tu izbrise red onda je apartman slobodan
-- triger pre unosa u tabelu iznajmljivanje:
--   1. Proverava se da li se za <smestaj> preklapa datum pocetka i datum kraja, i zabranjuje se unos u tom slucaju
--  [x]2. automatski se racuna broj_dana 
-- 
-- [x] 4. postavlja se status korisnika na 'active'
-- [x] 5. mora pri unosu da vazi datumPocetka < datumKraja  
-- [x] 6. Racuna se ukupan iznos cenaNoci


-- dodati prvo korisnika petar
-- okida trigere
/*
insert into Iznajmljivanje values 
(10050, 1000089 , date('2019-09-26'), date('2019-09-29'), 0 ,  now() ,null, 666, null);

select * from Iznajmljivanje;
select * from Korisnik;*/


-- delete from Iznajmljivanje where KorisnikID=10050 and smestajID=1000089;

use mydb;

delimiter $

drop trigger if exists ProveraIznajmljivanja$


create trigger ProveraIznajmljivanja before insert on Iznajmljivanje 
for each row 

begin 
	declare cena double;
	declare ukupno int;
	
	 set cena = (select cenaNoci from Smestaj s where s.smestajID=new.smestajID);
	
	-- 1da li se preklapaju dva iznajmljivanja istog smestaja 
	if exists(select * from Iznajmljivanje i where i.smestajID=new.smestajID and 
				(new.datumPocetka between i.datumPocetka and i.datumKraja or 
                new.datumKraja between i.datumPocetka and i.datumKraja))
                then signal sqlstate '45000' set message_text = 'Greska!Apartman je vec iznajmljen.';
	end if;
    
    -- 2da li su neispravno uneti datumi 
    if(new.datumKraja < new.datumPocetka)
        then signal sqlstate '45000' set message_text = 'Greska: Neispravan unos datuma, datum zavrsetka iznajmljivanja je manji od datuma pocetka iznajmljivanja!';
    else set new.brojDana = datediff(new.datumKraja, new.datumPocetka);
    end if;
    
	-- 2. da li se ispravno postavi ukupan_iznos 
	set new.ukupanIznos = cena*new.brojDana;
	
    -- 3. postavlja se status korisnika na active 
	update Korisnik set status='active' where korisnikID=new.korisnikID;
	
	
end$

-- tice se placanja, pre updateovanja placanja 
-- pre unosa iznosa za uplatu, proverava se da li je ukupan iznos jednak iznosu za uplatu 
-- '10050', '1000089', '2019-09-26', '2019-09-29', '3', '2018-12-21 18:21:27', NULL, '441', NULL

-- select * from Iznajmljivanje;

-- update Iznajmljivanje set uplaceno=150 where KorisnikID=10050 and SmestajID=1000089;


drop trigger if exists ProveraPlacanja$



CREATE TRIGGER ProveraPlacanja BEFORE UPDATE ON Iznajmljivanje
FOR EACH ROW 
BEGIN
	declare upl int;
    declare temp int;
    set temp = (old.ukupanIznos <= new.uplaceno);
    set upl = (select uplaceno from Iznajmljivanje where korisnikID=new.KorisnikID and SmestajID=new.SmestajID);
	-- provera iznosa pri vrsenju uplate 
    
    IF (temp=0)
		then signal sqlstate '45000' set message_text = 'Uplacen iznos mora da odgovara ukupnom iznosu!';    
    END IF;
   
	set new.datumUplate = now();
	
END$



create trigger NakonIznajmljivanja after delete on Iznajmljivanje 
for each row 
begin 
    declare temp int;
	-- provera da li postoji u tabeli iznajmljivanje taj korisnik, ako ne postoji onda se azurira na 'not active'
	set temp = (coalesce(old.ukupanIznos,0) <= coalesce(old.uplaceno,0));
	-- ovde ide provera da li je ukupaniznos jednak uplacenom iznosu u tom slucaju uvecaj booked
    if (temp=1) then
    update Korisnik set booked=booked+1 where korisnikID=old.korisnikID;
    end if;
   
   -- provera ako nema vise u tabeli iznajmljivanje ti onda stavi status na not active
   set temp = (select count(smestajID) from Iznajmljivanje where korisnikID=old.korisnikID);
   
   
   IF (temp=0) THEN
		update Korisnik set status='not active' where korisnikID=old.korisnikID;    
    END IF;
end$

delimiter ;

