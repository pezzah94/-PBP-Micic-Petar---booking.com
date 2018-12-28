-- 16, od toga 10 aktivno u iznajmljivanju
select *
from Smestaj s
left outer join Iznajmljivanje i 
	on s.smestajID = i.smestajID
JOIN VlasnistvoSmestaja vs
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid
       JOIN Lokacija l
         ON l.idlokacija = vs.lokacijaid
       JOIN OpisVlasnistvaSmestaja ovs
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
where vs.vlasnistvoSmestajaID=1004  AND s.brojkreveta >= 2
and date('2019-08-15') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02')) 
and date('2019-08-30') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02'));


  -- studenta 
SELECT s.smestajid,
       brojsoba,ovs.imaWifi,
       tipsmestaja,
       brojkreveta,
       imaklimu,
       imapogled,
       imabalkon,
       imaprivatnokupatilo,
       imaflatscreentv,
       vs.vlasnistvosmestajaid,
       cenanoci
FROM   Smestaj s
       JOIN VlasnistvoSmestaja vs
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid
       JOIN Lokacija l
         ON l.idlokacija = vs.lokacijaid
       JOIN OpisVlasnistvaSmestaja ovs
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
       left outer JOIN Iznajmljivanje i
         ON i.smestajid = s.smestajid
		
WHERE  l.drzava LIKE '%China%'
       AND s.brojkreveta >= 2
      
and date('2019-08-15') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02')) 
and date('2019-08-30') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02'))
group by s.smestajID
order by s.cenaNoci asc, ovs.imaWifi desc, ovs.noPrepayment desc, s.imaFlatScreenTv desc;
 
 
 -- provera koja skloni prikaz neiznajmljenih stanova, vremenom null
 -- i ako datum opkoraci vec postojeci
 
 
 -- zaposleni 
 
SELECT s.smestajid,
       brojsoba,ovs.imaWifi,
       tipsmestaja,
       brojkreveta,
       imaklimu,
       imapogled,
       imabalkon,
       imaprivatnokupatilo,
       imaflatscreentv,
       vs.vlasnistvosmestajaid,
       cenanoci
FROM   Smestaj s
       JOIN VlasnistvoSmestaja vs
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid
       JOIN Lokacija l
         ON l.idlokacija = vs.lokacijaid
       JOIN OpisVlasnistvaSmestaja ovs
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
       left outer JOIN Iznajmljivanje i
         ON i.smestajid = s.smestajid
		
WHERE  l.drzava LIKE '%Turkey%'
       AND s.brojkreveta >= 2
      
and date('2019-08-15') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02')) 
and date('2019-08-30') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02'))
group by s.smestajID
 order by s.cenaNoci asc,ovs.imaWifi desc, ovs.imaRoomService, ovs.imaParking desc,
 ovs.imaSpa desc, ovs.ukljucenDorucak;
 
 
 -- obicna lica 
SELECT s.smestajid,
       brojsoba,ovs.imaWifi,
       tipsmestaja,
       brojkreveta,
       imaklimu,
       imapogled,
       imabalkon,
       imaprivatnokupatilo,
       imaflatscreentv,
       vs.vlasnistvosmestajaid,
       cenanoci
FROM   Smestaj s
       JOIN VlasnistvoSmestaja vs
         ON vs.vlasnistvosmestajaid = s.vlasnistvosmestajaid
       JOIN Lokacija l
         ON l.idlokacija = vs.lokacijaid
       JOIN OpisVlasnistvaSmestaja ovs
		 on ovs.vlasnistvoSmestajaID=vs.vlasnistvoSmestajaID
       left outer JOIN Iznajmljivanje i
         ON i.smestajid = s.smestajid
		
WHERE  l.drzava LIKE '%Turkey%'
       AND s.brojkreveta >= 2
      
and date('2019-08-15') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02')) 
and date('2019-08-30') not between coalesce(i.datumPocetka, date('1900-01-01')) and coalesce(i.datumKraja, date('1900-01-02'))
group by s.smestajID 
order by s.cenaNoci desc, 



-- za dato VlasnistvoSmestaja vrati string nekih najblizih objekata i opis koliko su udaljeni 
 -- 'U blizini ' || vs.naziv || 'nalazi se' || o.naziv || 'na udaljenosti' || coalesce(o.opis, o.)
 
 select vs.naziv, concat('U blizini ', vs.naziv, 'nalazi se ', o.naziv, ' na udaljenosti ', coalesce(concat(d.opis, '.'), concat(d.km, ' kilometara.')))
 from VlasnistvoSmestaja vs join Distanca d
	on vs.vlasnistvoSmestajaID=d.vlasnistvoSmestajaID
join Objekti o
	on d.objektiID=o.objektiID

where vs.vlasnistvoSmestajaID=1004;


-- izlistavanje svih hotela na osnovu lokacije 

select vs.vlasnistvoSmestajaID, vs.naziv
from VlasnistvoSmestaja vs
join Lokacija l
	on vs.LokacijaID=l.idLokacija
where l.drzava like '%Turkey%'
