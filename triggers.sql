-- trigger 1:
-- iznajmljivanje cuva info o tekucim rezervacijama, kada se tu izbrise red onda je apartman slobodan
-- triger pre unosa u tabelu iznajmljivanje:
--        1. Proverava se da li se za <smestaj> preklapa datum pocetka i datum kraja, i zabranjuje se unos u tom slucaju
--  [x]2. automatski se racuna broj_dana 
--  3. unosi se red u tabelu Placanje, gde se racuna ukupna cena i ako je korisnik uplatio, postavlja se datum uplate, a inace null
--  4. postavlja se status korisnika na 'active'
-- [x] 5. mora pri unosu da vazi datumPocetka < datumKraja !! 

drop trigger IznajmljivanjeRestrict;

use delimiter $
create trigger IznajmljivanjeRestrict before insert on Iznajmljivanje 
for each row 

begin 

	if exists(select * from Iznajmljivanje i where i.smestajID=new.smestajID and 
				(new.datumPocetka between i.datumPocetka and i.datumKraja or 
                new.datumKraja between i.datumPocetka and i.datumKraja))
                then signal sqlstate '45000' set message_text = 'Greska!...';
	end if;
    
    
    if(new.datumKraja < new.datumPocetka)
        then signal sqlstate '45000' set message_text = "Greska: Neispravan unos datuma, datum zavrsetka iznajmljivanja je manji od datuma pocetka iznajmljivanja!";
    else set new.brojDana = datediff(new.datumKraja, new.datumPocetka);
    end if;
    
    
	
end

-- u tabelu placanje sa automatski insertuje, ona se samo azurira 
-- automatski se brise iz tabele placanje, nakon sto se izbrise iz tabele Iznajmljivanje
-- trigger 2: 
use delimiter $
create trigger PlacanjeRestrict before update on Placanje 
for each row 
begin 
	if (old.ukupanIznos <= new.uplaceno) then signal sqlstate '45000' set message_text = 'Greska!';
    end if;
    
   
end$
