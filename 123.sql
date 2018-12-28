USE DELIMITER $
create trigger NakonIznajmljivanja before delete on Iznajmljivanje 
for each row 
begin 
    declare temp int;
	-- provera da li postoji u tabeli iznajmljivanje taj korisnik, ako ne postoji onda se azurira na 'not active'
    update Korisnik set booked=booked+1 where korisnikID=korisnikID;
   
   
   -- provera ako nema vise u tabeli iznajmljivanje ti onda stavi status na not active
   set temp = (select count(smestajID) from Iznajmljivanje where korisnikID=old.korisnikID);
   
   IF (temp=0) THEN
		update Korisnik set status='not active' where korisnikID=old.korisnikID;    
    END IF;
end$
case 
	when s.korisnikID is not null then 0 
    when z.zaposlenID is not null then 1
    when l.liceID is not null then 2
end) as Tip


set @check1 = (
select smestajID, case when(ukupanIznos=uplaceno) then 1 else 0 end as C from Iznajmljivanje where korisnikID=10050
)

select @check1
from Iznajmljivanje