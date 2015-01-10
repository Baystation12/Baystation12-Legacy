-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.6.20 - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL Version:             9.1.0.4867
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table luna.admins
CREATE TABLE IF NOT EXISTS `admins` (
  `ckey` varchar(255) NOT NULL,
  `rank` int(1) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.admins: 1 rows
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` (`ckey`, `rank`) VALUES
	('headswe', 6);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;


-- Dumping structure for table luna.backpack
CREATE TABLE IF NOT EXISTS `backpack` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPE` (`ckey`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.backpack: 0 rows
/*!40000 ALTER TABLE `backpack` DISABLE KEYS */;
/*!40000 ALTER TABLE `backpack` ENABLE KEYS */;


-- Dumping structure for table luna.bans
CREATE TABLE IF NOT EXISTS `bans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(1) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minute` int(255) NOT NULL DEFAULT '0',
  `timebanned` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.bans: 0 rows
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;


-- Dumping structure for table luna.booklog
CREATE TABLE IF NOT EXISTS `booklog` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'INSERT',
  `title` text NOT NULL,
  `author` varchar(256) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.booklog: 0 rows
/*!40000 ALTER TABLE `booklog` DISABLE KEYS */;
/*!40000 ALTER TABLE `booklog` ENABLE KEYS */;


-- Dumping structure for table luna.books
CREATE TABLE IF NOT EXISTS `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(2) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=138 DEFAULT CHARSET=latin1;

-- Dumping data for table luna.books: 0 rows
/*!40000 ALTER TABLE `books` DISABLE KEYS */;
/*!40000 ALTER TABLE `books` ENABLE KEYS */;


-- Dumping structure for table luna.changelog
CREATE TABLE IF NOT EXISTS `changelog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bywho` varchar(255) NOT NULL,
  `changes` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

-- Dumping data for table luna.changelog: 0 rows
/*!40000 ALTER TABLE `changelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `changelog` ENABLE KEYS */;


-- Dumping structure for table luna.config
CREATE TABLE IF NOT EXISTS `config` (
  `motd` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.config: 0 rows
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
/*!40000 ALTER TABLE `config` ENABLE KEYS */;


-- Dumping structure for table luna.crban
CREATE TABLE IF NOT EXISTS `crban` (
  `ckey` varchar(255) NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL COMMENT 'Why the ban was placed',
  `bannedby` varchar(255) NOT NULL COMMENT 'Who set the ban',
  `time` datetime NOT NULL COMMENT 'When the ban was placed',
  `unban_time` datetime DEFAULT NULL COMMENT 'When the loser should be Unbanned',
  PRIMARY KEY (`ckey`),
  KEY `bannedby` (`bannedby`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.crban: 0 rows
/*!40000 ALTER TABLE `crban` DISABLE KEYS */;
/*!40000 ALTER TABLE `crban` ENABLE KEYS */;


-- Dumping structure for table luna.crban_past
CREATE TABLE IF NOT EXISTS `crban_past` (
  `CKey` varchar(255) NOT NULL COMMENT 'Who was banned',
  `Banner` varchar(255) NOT NULL COMMENT 'Who banned them',
  `BanReason` text NOT NULL COMMENT 'Why they were banned',
  `BanTime` datetime NOT NULL COMMENT 'When the ban was placed',
  `UnbanTime` datetime DEFAULT NULL COMMENT 'When the ban was supposed to be lifted',
  `Unbanned` datetime DEFAULT NULL COMMENT 'If not null, when the ban was lifted early',
  `Unbanner` varchar(255) DEFAULT NULL COMMENT 'Who unbanned them early',
  KEY `CKey` (`CKey`),
  KEY `Banner` (`Banner`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Record of all the past bans';

-- Dumping data for table luna.crban_past: 0 rows
/*!40000 ALTER TABLE `crban_past` DISABLE KEYS */;
/*!40000 ALTER TABLE `crban_past` ENABLE KEYS */;


-- Dumping structure for table luna.currentplayers
CREATE TABLE IF NOT EXISTS `currentplayers` (
  `name` varchar(255) NOT NULL,
  `playing` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.currentplayers: 0 rows
/*!40000 ALTER TABLE `currentplayers` DISABLE KEYS */;
/*!40000 ALTER TABLE `currentplayers` ENABLE KEYS */;


-- Dumping structure for table luna.deathlog
CREATE TABLE IF NOT EXISTS `deathlog` (
  `ckey` varchar(255) NOT NULL,
  `location` text NOT NULL,
  `lastattacker` text NOT NULL,
  `ToD` text NOT NULL,
  `health` text NOT NULL,
  `lasthit` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.deathlog: 0 rows
/*!40000 ALTER TABLE `deathlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `deathlog` ENABLE KEYS */;


-- Dumping structure for table luna.invites
CREATE TABLE IF NOT EXISTS `invites` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.invites: 0 rows
/*!40000 ALTER TABLE `invites` DISABLE KEYS */;
/*!40000 ALTER TABLE `invites` ENABLE KEYS */;


-- Dumping structure for table luna.jobban
CREATE TABLE IF NOT EXISTS `jobban` (
  `ckey` varchar(255) NOT NULL,
  `rank` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.jobban: 0 rows
/*!40000 ALTER TABLE `jobban` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobban` ENABLE KEYS */;


-- Dumping structure for table luna.jobbanlog
CREATE TABLE IF NOT EXISTS `jobbanlog` (
  `ckey` varchar(255) NOT NULL COMMENT 'By who',
  `targetckey` varchar(255) NOT NULL COMMENT 'Target',
  `rank` varchar(255) NOT NULL COMMENT 'rank',
  `when` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when',
  `why` varchar(355) NOT NULL,
  UNIQUE KEY `targetckey` (`targetckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.jobbanlog: 0 rows
/*!40000 ALTER TABLE `jobbanlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobbanlog` ENABLE KEYS */;


-- Dumping structure for table luna.medals
CREATE TABLE IF NOT EXISTS `medals` (
  `ckey` varchar(255) NOT NULL,
  `medal` text NOT NULL,
  `medaldesc` text NOT NULL,
  `medaldiff` text NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`,`medal`(8))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.medals: 5 rows
/*!40000 ALTER TABLE `medals` DISABLE KEYS */;
INSERT INTO `medals` (`ckey`, `medal`, `medaldesc`, `medaldiff`) VALUES
	('headswe', 'First Timer', 'Welcome!', 'easy'),
	('headswe', 'Downsizing', 'You are no longer a profitable asset.', 'easy'),
	('headswe', 'Broke Yarrr Bones!', 'Break a bone.', 'easy'),
	('wingman89', 'First Timer', 'Welcome!', 'easy'),
	('zuhayr', 'First Timer', 'Welcome!', 'easy');
/*!40000 ALTER TABLE `medals` ENABLE KEYS */;


-- Dumping structure for table luna.players
CREATE TABLE IF NOT EXISTS `players` (
  `index` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(255) NOT NULL,
  `slot` tinyint(4) NOT NULL,
  `slotname` tinytext NOT NULL,
  `real_name` tinytext NOT NULL,
  `gender` tinytext NOT NULL,
  `age` tinyint(4) NOT NULL,
  `occupation1` tinytext NOT NULL,
  `occupation2` tinytext NOT NULL,
  `occupation3` tinytext NOT NULL,
  `hair_color` tinytext NOT NULL,
  `facial_color` tinytext NOT NULL,
  `skin_tone` tinyint(4) NOT NULL,
  `hairstyle` tinytext NOT NULL,
  `facialstyle` tinytext NOT NULL,
  `eyecolor` tinytext NOT NULL,
  `bloodtype` tinytext NOT NULL,
  `be_syndicate` tinyint(4) NOT NULL,
  `be_nuke_agent` tinyint(4) NOT NULL,
  `be_takeover_agent` tinyint(4) NOT NULL,
  `underwear` tinyint(4) NOT NULL,
  `name_is_always_random` tinyint(4) NOT NULL,
  `bios` text NOT NULL,
  `disabilities` tinyint(4) NOT NULL,
  PRIMARY KEY (`index`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Dumping data for table luna.players: ~3 rows (approximately)
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` (`index`, `ckey`, `slot`, `slotname`, `real_name`, `gender`, `age`, `occupation1`, `occupation2`, `occupation3`, `hair_color`, `facial_color`, `skin_tone`, `hairstyle`, `facialstyle`, `eyecolor`, `bloodtype`, `be_syndicate`, `be_nuke_agent`, `be_takeover_agent`, `underwear`, `name_is_always_random`, `bios`, `disabilities`) VALUES
	(1, 'headswe', 1, 'Default', 'Minkot Boat', 'male', 30, 'Atmospheric Technician', 'No Preference', 'No Preference', '#000000', '#000000', 0, 'Short Hair', 'Shaved', '#000000', 'A+', 1, 1, 1, 1, 0, 'Nothing here yet...', 0),
	(2, 'headswe', 2, 'Default', 'Nomal Human', 'male', 30, 'No Preference', 'No Preference', 'No Preference', '#000000', '#000000', 0, 'Short Hair', 'Shaved', '#000000', 'A+', 0, 0, 0, 1, 0, 'Nothing here yet...', 0),
	(3, 'zuhayr', 1, 'Default', 'Oddum Human', 'male', 30, 'No Preference', 'No Preference', 'No Preference', '#000000', '#000000', 0, 'Short Hair', 'Shaved', '#000000', 'A+', 0, 0, 0, 1, 0, 'Nothing here yet...', 0);
/*!40000 ALTER TABLE `players` ENABLE KEYS */;


-- Dumping structure for table luna.ranks
CREATE TABLE IF NOT EXISTS `ranks` (
  `Rank` int(11) NOT NULL COMMENT 'What Numeric Rank',
  `Desc` text NOT NULL COMMENT 'What is a person with this rank?',
  PRIMARY KEY (`Rank`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.ranks: 6 rows
/*!40000 ALTER TABLE `ranks` DISABLE KEYS */;
INSERT INTO `ranks` (`Rank`, `Desc`) VALUES
	(6, 'Host'),
	(5, 'Coder'),
	(4, 'Super Administrator'),
	(3, 'Primary Administrator'),
	(2, 'Administrator'),
	(1, 'Secondary Administrator');
/*!40000 ALTER TABLE `ranks` ENABLE KEYS */;


-- Dumping structure for table luna.roundsjoined
CREATE TABLE IF NOT EXISTS `roundsjoined` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.roundsjoined: 0 rows
/*!40000 ALTER TABLE `roundsjoined` DISABLE KEYS */;
/*!40000 ALTER TABLE `roundsjoined` ENABLE KEYS */;


-- Dumping structure for table luna.roundsurvived
CREATE TABLE IF NOT EXISTS `roundsurvived` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.roundsurvived: 0 rows
/*!40000 ALTER TABLE `roundsurvived` DISABLE KEYS */;
/*!40000 ALTER TABLE `roundsurvived` ENABLE KEYS */;


-- Dumping structure for table luna.stats
CREATE TABLE IF NOT EXISTS `stats` (
  `ckey` varchar(255) NOT NULL COMMENT 'ckey',
  `deaths` int(10) NOT NULL DEFAULT '0' COMMENT 'player deaths',
  `roundsplayed` int(10) NOT NULL DEFAULT '0' COMMENT 'rounds played',
  `suicides` int(10) NOT NULL DEFAULT '0' COMMENT 'suicides',
  `traitorwin` int(10) NOT NULL DEFAULT '0' COMMENT 'traitor wins',
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.stats: 0 rows
/*!40000 ALTER TABLE `stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats` ENABLE KEYS */;


-- Dumping structure for table luna.suggest
CREATE TABLE IF NOT EXISTS `suggest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` text NOT NULL,
  `link` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

-- Dumping data for table luna.suggest: 0 rows
/*!40000 ALTER TABLE `suggest` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggest` ENABLE KEYS */;


-- Dumping structure for table luna.traitorbuy
CREATE TABLE IF NOT EXISTS `traitorbuy` (
  `type` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.traitorbuy: 0 rows
/*!40000 ALTER TABLE `traitorbuy` DISABLE KEYS */;
/*!40000 ALTER TABLE `traitorbuy` ENABLE KEYS */;


-- Dumping structure for table luna.traitorlogs
CREATE TABLE IF NOT EXISTS `traitorlogs` (
  `CKey` varchar(128) NOT NULL,
  `Objective` text NOT NULL,
  `Succeeded` tinyint(4) NOT NULL,
  `Spawned` text NOT NULL,
  `Occupation` varchar(128) NOT NULL,
  `PlayerCount` int(11) NOT NULL,
  KEY `CKey` (`CKey`),
  KEY `Succeeded` (`Succeeded`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table luna.traitorlogs: ~0 rows (approximately)
/*!40000 ALTER TABLE `traitorlogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `traitorlogs` ENABLE KEYS */;


-- Dumping structure for table luna.unbans
CREATE TABLE IF NOT EXISTS `unbans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(255) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minutes` int(255) NOT NULL,
  `timebanned` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.unbans: 0 rows
/*!40000 ALTER TABLE `unbans` DISABLE KEYS */;
/*!40000 ALTER TABLE `unbans` ENABLE KEYS */;


-- Dumping structure for table luna.voters
CREATE TABLE IF NOT EXISTS `voters` (
  `username` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL,
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table luna.voters: 0 rows
/*!40000 ALTER TABLE `voters` DISABLE KEYS */;
/*!40000 ALTER TABLE `voters` ENABLE KEYS */;


-- Dumping structure for table luna.web_log
CREATE TABLE IF NOT EXISTS `web_log` (
  `type` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `bywho` varchar(255) NOT NULL,
  `time` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping data for table luna.web_log: 0 rows
/*!40000 ALTER TABLE `web_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_log` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
