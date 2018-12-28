-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Korisnik`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Korisnik` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Korisnik` (
  `KorisnikID` INT(11) NOT NULL,
  `imeKorisnika` VARCHAR(50) NOT NULL,
  `prezimeKorisnika` VARCHAR(45) NOT NULL,
  `datumRodjenja` DATE NULL DEFAULT NULL,
  `status` VARCHAR(45) NOT NULL,
  `booked` INT NULL,
  PRIMARY KEY (`KorisnikID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Lice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Lice` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Lice` (
  `liceID` INT(11) NOT NULL,
  PRIMARY KEY (`liceID`),
  INDEX `fk_Lice_Korisnik1_idx` (`liceID` ASC),
  CONSTRAINT `fk_Lice_Korisnik1`
    FOREIGN KEY (`liceID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Dete`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Dete` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Dete` (
  `deteID` INT(11) NOT NULL,
  `liceID` INT(11) NOT NULL,
  `ime` VARCHAR(45) NULL DEFAULT NULL,
  `godine` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`deteID`, `liceID`),
  INDEX `fk_Dete_1_idx` (`liceID` ASC),
  CONSTRAINT `fk_Dete_1`
    FOREIGN KEY (`liceID`)
    REFERENCES `mydb`.`Lice` (`liceID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Objekti`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Objekti` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Objekti` (
  `objektiID` INT(11) NOT NULL,
  `naziv` VARCHAR(256) NULL DEFAULT NULL,
  `ulica` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`objektiID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Lokacija`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Lokacija` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Lokacija` (
  `idLokacija` INT(11) NOT NULL,
  `naziv` VARCHAR(256) NULL DEFAULT NULL,
  `postcode` VARCHAR(256) NULL DEFAULT NULL,
  `drzava` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`idLokacija`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`VlasnistvoSmestaja`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`VlasnistvoSmestaja` ;

CREATE TABLE IF NOT EXISTS `mydb`.`VlasnistvoSmestaja` (
  `vlasnistvoSmestajaID` INT(11) NOT NULL,
  `tipVlasnistvaSmestaja` VARCHAR(256) NULL DEFAULT NULL,
  `naziv` VARCHAR(256) NULL DEFAULT NULL,
  `ulica` VARCHAR(256) NULL DEFAULT NULL,
  `brojTelefona` VARCHAR(256) NULL DEFAULT NULL,
  `email` VARCHAR(256) NULL DEFAULT NULL,
  `LokacijaID` INT(11) NOT NULL,
  PRIMARY KEY (`vlasnistvoSmestajaID`),
  INDEX `fk_VlasnistvoSmestaja_Lokacija1_idx` (`LokacijaID` ASC),
  CONSTRAINT `fk_VlasnistvoSmestaja_Lokacija1`
    FOREIGN KEY (`LokacijaID`)
    REFERENCES `mydb`.`Lokacija` (`idLokacija`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Distanca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Distanca` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Distanca` (
  `objektiID` INT(11) NULL,
  `vlasnistvoSmestajaID` INT(11) NULL,
  `opis` VARCHAR(45) NULL DEFAULT NULL,
  `km` INT(11) NULL DEFAULT NULL,
  INDEX `fk_Distanca_1_idx` (`objektiID` ASC),
  INDEX `fk_Distanca_2_idx` (`vlasnistvoSmestajaID` ASC),
  CONSTRAINT `fk_Distanca_1`
    FOREIGN KEY (`objektiID`)
    REFERENCES `mydb`.`Objekti` (`objektiID`),
  CONSTRAINT `fk_Distanca_2`
    FOREIGN KEY (`vlasnistvoSmestajaID`)
    REFERENCES `mydb`.`VlasnistvoSmestaja` (`vlasnistvoSmestajaID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Smestaj`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Smestaj` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Smestaj` (
  `smestajID` INT(11) NOT NULL,
  `brojSoba` INT(11) NOT NULL,
  `tipSmestaja` VARCHAR(256) NOT NULL,
  `brojKreveta` INT(11) NOT NULL,
  `imaKlimu` TINYINT(1) NULL DEFAULT NULL,
  `imaPogled` TINYINT(1) NULL DEFAULT NULL,
  `imaBalkon` TINYINT(1) NULL DEFAULT NULL,
  `imaPrivatnoKupatilo` TINYINT(1) NULL DEFAULT NULL,
  `imaFlatScreenTv` TINYINT(1) NULL DEFAULT NULL,
  `forCouples` TINYINT(1) NULL,
  `vlasnistvoSmestajaID` INT(11) NOT NULL,
  `cenaNoci` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`smestajID`),
  INDEX `fk_Smestaj_VlasnistvoSmestaja1_idx` (`vlasnistvoSmestajaID` ASC),
  CONSTRAINT `fk_Smestaj_VlasnistvoSmestaja1`
    FOREIGN KEY (`vlasnistvoSmestajaID`)
    REFERENCES `mydb`.`VlasnistvoSmestaja` (`vlasnistvoSmestajaID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`OceneSmestaja`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`OceneSmestaja` ;

CREATE TABLE IF NOT EXISTS `mydb`.`OceneSmestaja` (
  `korisnikID` INT(11) NOT NULL,
  `smestajID` INT(11) NOT NULL,
  `cistoca` INT(11) NOT NULL,
  `lokacija` INT(11) NOT NULL DEFAULT '0',
  `osoblje` INT(11) NOT NULL,
  `usluge` INT(11) NOT NULL,
  `komfort` INT(11) NOT NULL,
  `datumOcene` DATETIME NOT NULL,
  `komentar` VARCHAR(800) NULL DEFAULT 'no comment',
  PRIMARY KEY (`korisnikID`, `smestajID`),
  INDEX `SmestajFK_idx` (`smestajID` ASC),
  CONSTRAINT `SmestajFK`
    FOREIGN KEY (`smestajID`)
    REFERENCES `mydb`.`Smestaj` (`smestajID`),
  CONSTRAINT `fk_OceneSmestaja_1`
    FOREIGN KEY (`korisnikID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`OpisVlasnistvaSmestaja`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`OpisVlasnistvaSmestaja` ;

CREATE TABLE IF NOT EXISTS `mydb`.`OpisVlasnistvaSmestaja` (
  `vlasnistvoSmestajaID` INT(11) NOT NULL,
  `imaBar` TINYINT(1) NULL DEFAULT NULL,
  `imaSpa` TINYINT(1) NULL DEFAULT NULL,
  `imaParking` TINYINT(1) NULL DEFAULT NULL,
  `imaRoomService` TINYINT(1) NULL DEFAULT NULL,
  `imaWifi` TINYINT(1) NULL DEFAULT NULL,
  `ljubimci` TINYINT(1) NULL DEFAULT NULL,
  `ukljucenDorucak` TINYINT(1) NULL DEFAULT NULL,
  `noPrepayment` TINYINT(1) NULL DEFAULT NULL,
  `disabledGuestFascilities` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`vlasnistvoSmestajaID`),
  CONSTRAINT `fk_OpisVlasnistvaSmestaja_VlasnistvoSmestaja1`
    FOREIGN KEY (`vlasnistvoSmestajaID`)
    REFERENCES `mydb`.`VlasnistvoSmestaja` (`vlasnistvoSmestajaID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Student`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Student` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Student` (
  `KorisnikID` INT(11) NOT NULL,
  `indeks` VARCHAR(15) NULL DEFAULT NULL,
  `Naziv univerziteta` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`KorisnikID`),
  INDEX `KorisnikID_idx` (`KorisnikID` ASC),
  CONSTRAINT `strani kljuc`
    FOREIGN KEY (`KorisnikID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Zaposlen`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Zaposlen` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Zaposlen` (
  `zaposlenID` INT(11) NOT NULL,
  `zanimanje` VARCHAR(256) NULL DEFAULT NULL,
  `nazivFirme` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`zaposlenID`),
  CONSTRAINT `fk_Zaposlen_1`
    FOREIGN KEY (`zaposlenID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Iznajmljivanje`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Iznajmljivanje` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Iznajmljivanje` (
  `korisnikID` INT(11) NULL,
  `smestajID` INT(11) NULL,
  `datumPocetka` DATE NULL,
  `datumKraja` DATE NULL,
  `brojDana` INT NULL,
  `vremeIznajmljivanja` DATETIME NULL,
  `datumUplate` DATETIME NULL,
  `ukupanIznos` INT NULL,
  `uplaceno` INT NULL,
  INDEX `fk_Korisnik_has_Smestaj_Smestaj1_idx` (`smestajID` ASC),
  INDEX `fk_Korisnik_has_Smestaj_Korisnik1_idx` (`korisnikID` ASC),
  CONSTRAINT `fk_Korisnik_has_Smestaj_Korisnik1`
    FOREIGN KEY (`korisnikID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Korisnik_has_Smestaj_Smestaj1`
    FOREIGN KEY (`smestajID`)
    REFERENCES `mydb`.`Smestaj` (`smestajID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `mydb`.`Veza`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Veza` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Veza` (
  `KorisnikID` INT(11) NOT NULL,
  `inRelKorisnikID` INT(11) NOT NULL,
  PRIMARY KEY (`KorisnikID`, `inRelKorisnikID`),
  INDEX `fk_Korisnik_has_Korisnik_Korisnik2_idx` (`inRelKorisnikID` ASC),
  INDEX `fk_Korisnik_has_Korisnik_Korisnik1_idx` (`KorisnikID` ASC),
  CONSTRAINT `fk_Korisnik_has_Korisnik_Korisnik1`
    FOREIGN KEY (`KorisnikID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Korisnik_has_Korisnik_Korisnik2`
    FOREIGN KEY (`inRelKorisnikID`)
    REFERENCES `mydb`.`Korisnik` (`KorisnikID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
