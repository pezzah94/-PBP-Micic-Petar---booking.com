-- korisnik kreira nalog 
-- bira da li je student ili zaposlen, inace je Lice
-- popunjava elementarne podatke 
select * from Korisnik;

insert into Korisnik values 
(kkk, Petar, Micic, date('1994-06-28');

select * from Student;

insert into Student values 
(<autovalue>, '1104/2018', 'Matematicki fakultet', kkk);


-- brisanje korisnika iz sistema 
-- okidac proverava da li ima iznajmljivanje, da li su izmireni svi dugovi, i ako je komentarisao apartmane, postavlja ime komentatora na null (nepoznat) a zadrzavaju se ocene i komentar

delete from Korisnik
where korisnikID=kkk;








select * from Iznajmljivanje i join Smestaj s
	on i.smestajID=s.smestajID
join VlasnistvoSmestaja vs
	on vs.vlasnistvoSmestajaID = s.vlasnistvoSmestajaID
join OpisVlasnistvaSmestaja ovs
	on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
join Lokacija l
	on l.idLokacija = vs.LokacijaID
left outer join OceneSmestaja os
	on os.smestajID=s.smestajID
where i.korisnikID = 10015;

-- za zadate sledece input parametre izlistati sve raspolozive smestaje, kao i o
-- input: naziv lokacije, broj osoba, datumPocetka, datum kraja 
-- values: 'Instabul',  2, date('2019-03-15'), date(2019-03-25)
-- output izlistati sve raspolozive smestaje
-- 

select * from Lokacija;


select s.smestajID,brojSoba,tipSmestaja,brojKreveta,imaKlimu,imaPogled,imaBalkon,imaPrivatnoKupatilo,imaFlatScreenTv,vs.vlasnistvoSmestajaID,cenaNoci
from Smestaj s join VlasnistvoSmestaja vs
	on vs.vlasnistvoSmestajaID=s.vlasnistvoSmestajaID
join Lokacija l
	on l.idLokacija=vs.LokacijaID
join Iznajmljivanje i
	on i.smestajID=s.smestajID
where l.naziv like '%Istanbul%' and s.brojKreveta >= 2
and date('2019-03-15') not between datumPocetka and datumKraja and date('2019-03-25') not between datumPocetka and datumKraja;

-- korisnik se opredelio za smestaj i iznajmljuje ga 
-- input parametri su: korisnikID, smestajID, datumP, datumKraja, brojKreveta, opcija[placa ili ne]
-- output: uspesno insertovan (rezervisan) red u tabeli iznajmljivanje 

-- hocu ovaj: '1000066', '3', 'Vacation home ', '3', '1', '0', '0', '0', '0', '1004', '806'
select * from Iznajmljivanje;


--  rezervacija smestaja, unosenje u tabelu Iznajmljivanje
insert into Iznajmljivanje values 
(kkk, 1000066 , date('2019-03-15'), date('2019-03-25'),  2 ,  now());

-- red u tabeli placanje se unosi automatski u zavisnosti od opcije koju korisnik odabere 

-- naknadno placanje korisnika, opcija izvrsi uplatu


select * from Placanje;

-- aktivno je iznajmljivanje i tu citamo korisnika i smestaj, i
-- okida triger
-- 1. Mora da je uplaceno >= od ukupnog iznosa 

update Placanje 
set uplaceno = 1610
where korisnikID=kkk and smestajID=1000066;


-- nakon nekog vremena korisnik je odlucio da oceni smestaj 
select k.imeKorisnika,k.korisnikID,smestajID,cistoca,lokacija,osoblje,usluge,komfort,datumOcene,komentar
 from OceneSmestaja os
 join Korisnik k
	on os.KorisnikID=k.KorisnikID
    

insert into OceneSmestaja values 
(kkk, 1000066, 8, 7, 9, 9, 9, now(), 'Everything was so perfect.');


-- korisnik je zavrsio sa uslugama i sada se brise iz tabele Iznajmljivanje, okida triger 
delete from Iznajmljivanje
where korisnikID=kkk and smestajID=1000066;


-- za dati korisnikID ako je student 


select k.korisnikID as Korisnik, k.imeKorisnika as Ime,
(
case 
	when s.korisnikID is not null then 0 
    when z.zaposlenID is not null then 1
    when l.liceID is not null then 2
end) as Tip
from Korisnik k
left outer join Student s
	on k.korisnikID=s.KorisnikID
left outer join Zaposlen z
	on k.KorisnikID=z.zaposlenID
left outer join Lice l
	on l.liceID=k.korisnikID
where k.imeKorisnika like '%Lilian%';

-- za studenta 


select * from Iznajmljivanje;




select *
from Smestaj s join VlasnistvoSmestaja vs
	on vs.vlasnistvoSmestajaID=s.vlasnistvoSmestajaID
join Lokacija l
	on l.idLokacija=vs.LokacijaID
join OpisVlasnistvaSmestaja ovs
	on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
where  -- ovs.imaWifi=1 and ovs.noPrepayment=1 and s.imaKlimu=1 and s.imaFlatScreenTv=1 and 
s.smestajID not in (
select s.smestajID
from Iznajmljivanje i
	join Smestaj s
on s.SmestajID = i.SmestajID
	join VlasnistvoSmestaja vs
on vs.VlasnistvoSmestajaID = s.VlasnistvoSmestajaID
	join Lokacija l
on l.idLokacija=vs.lokacijaID
where l.drzava like '%Turkey%' and date('2019-03-22') not between i.datumPocetka and i.datumKraja
and date('2019-03-25') not between i.datumPocetka and i.datumKraja
)
order by cenaNoci asc;

select k.korisnikID as Korisnik, k.imeKorisnika as Ime, (case         when s.korisnikID is not null then 0     when z.zaposlenID is not null then 1     when l.liceID is not null then 'Lice' end) as Tip from Korisnik k left outer join Student s  on k.korisnikID=s.KorisnikID left outer join Zaposlen z         on k.KorisnikID=z.zaposlenID left outer join Lice l     on l.liceID=k.korisnikID where k.imeKorisnika like '%Alissa%'
