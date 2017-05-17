CREATE TABLE IF NOT EXISTS admins (
  ckey TEXT PRIMARY KEY NOT NULL,
  rank INTEGER NOT NULL
);

INSERT OR REPLACE INTO admins (ckey, rank) VALUES
	('headswe', 6);


CREATE TABLE IF NOT EXISTS backpack (
  ckey TEXT PRIMARY KEY NOT NULL,
  type TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS bans (
  ckey       TEXT PRIMARY KEY NOT NULL,
  computerid TEXT NOT NULL,
  ips        TEXT NOT NULL,
  reason     TEXT NOT NULL,
  bannedby   TEXT NOT NULL,
  temp       INTEGER NOT NULL, --0 = permabanned
  minute     INTEGER NOT NULL DEFAULT 0,
  timebanned TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS books (
  id     INTEGER PRIMARY KEY ASC,
  ckey   TEXT NOT NULL,
  title  TEXT NOT NULL,
  author TEXT NOT NULL,
  text   TEXT NOT NULL,
  cat    INTEGER NOT NULL DEFAULT 1
);


CREATE TABLE IF NOT EXISTS changelog (
  id      INTEGER PRIMARY KEY ASC,
  bywho   TEXT NOT NULL,
  changes TEXT NOT NULL,
  date    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


--IDK what uses this.
CREATE TABLE IF NOT EXISTS config (
  motd TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS crban (
  ckey       TEXT PRIMARY KEY NOT NULL,
  ips        TEXT NOT NULL,
  reason     TEXT NOT NULL,        --Why the ban was placed
  bannedby   TEXT NOT NULL,        --Who set the ban
  time       DATETIME NOT NULL,    --When the ban was placed
  unban_time DATETIME DEFAULT NULL --When the loser should be Unbanned
);
CREATE INDEX IF NOT EXISTS crban_bannedby ON crban (bannedby);


--IDK why the columns aren't lowercase here.
CREATE TABLE IF NOT EXISTS crban_past (
  CKey      TEXT NOT NULL,         --Who was banned
  Banner    TEXT NOT NULL,         --Who banned them
  BanReason TEXT NOT NULL,         --Why they were banned
  BanTime   DATETIME NOT NULL,     --When the ban was placed
  UnbanTime DATETIME DEFAULT NULL, --When the ban was supposed to be lifted
  Unbanned  DATETIME DEFAULT NULL, --If not null, when the ban was lifted early
  Unbanner  TEXT DEFAULT NULL      --Who unbanned them early
);
CREATE INDEX IF NOT EXISTS crban_past_ckey ON crban_past (CKey);
CREATE INDEX IF NOT EXISTS crban_past_banner ON crban_past (Banner);


CREATE TABLE IF NOT EXISTS currentplayers (
  name    TEXT PRIMARY KEY NOT NULL,
  playing INTEGER NOT NULL DEFAULT 1
);


CREATE TABLE IF NOT EXISTS deathlog (
  ckey         TEXT NOT NULL,
  location     TEXT NOT NULL,
  lastattacker TEXT NOT NULL,
  ToD          TEXT NOT NULL,
  health       TEXT NOT NULL,
  lasthit      TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS invites (
  ckey TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS jobban (
  ckey TEXT NOT NULL,
  rank TEXT NOT NULL,
  UNIQUE (ckey, rank) ON CONFLICT IGNORE
);
CREATE INDEX IF NOT EXISTS jobban_ckey ON jobban (ckey);


CREATE TABLE IF NOT EXISTS jobbanlog (
  ckey       TEXT NOT NULL,                                --By who
  targetckey TEXT NOT NULL,                                --Target
  rank       TEXT NOT NULL,                                --rank
  'when'       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, --when
  why        TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS jobbanlog_ckey ON jobbanlog (ckey);


CREATE TABLE IF NOT EXISTS medals (
  ckey      TEXT NOT NULL,
  medal     TEXT NOT NULL,
  medaldesc TEXT NOT NULL,
  medaldiff TEXT NOT NULL,
  UNIQUE (ckey, medal) ON CONFLICT IGNORE
);
CREATE INDEX IF NOT EXISTS medals_ckey ON medals (ckey);

INSERT INTO medals (ckey, medal, medaldesc, medaldiff) VALUES
	('headswe', 'First Timer', 'Welcome!', 'easy'),
	('headswe', 'Downsizing', 'You are no longer a profitable asset.', 'easy'),
	('headswe', 'Broke Yarrr Bones!', 'Break a bone.', 'easy'),
	('wingman89', 'First Timer', 'Welcome!', 'easy'),
	('zuhayr', 'First Timer', 'Welcome!', 'easy');


CREATE TABLE IF NOT EXISTS players (
  'index'               INTEGER PRIMARY KEY ASC,
  ckey                  TEXT NOT NULL,
  slot                  INTEGER NOT NULL,
  slotname              TEXT NOT NULL,
  real_name             TEXT NOT NULL,
  gender                TEXT NOT NULL,
  age                   INTEGER NOT NULL,
  occupation1           TEXT NOT NULL,
  occupation2           TEXT NOT NULL,
  occupation3           TEXT NOT NULL,
  hair_color            TEXT NOT NULL,
  facial_color          TEXT NOT NULL,
  skin_tone             INTEGER NOT NULL,
  hairstyle             TEXT NOT NULL,
  facialstyle           TEXT NOT NULL,
  eyecolor              TEXT NOT NULL,
  bloodtype             TEXT NOT NULL,
  be_syndicate          INTEGER NOT NULL,
  be_nuke_agent         INTEGER NOT NULL,
  be_takeover_agent     INTEGER NOT NULL,
  underwear             INTEGER NOT NULL,
  name_is_always_random INTEGER NOT NULL,
  bios                  TEXT NOT NULL,
  disabilities          INTEGER NOT NULL
);



CREATE TABLE IF NOT EXISTS ranks (
  Rank INTEGER NOT NULL, --What Numeric Rank
  Desc TEXT NOT NULL     --What is a person with this rank?
);

INSERT INTO ranks (Rank, Desc) VALUES
	(6, 'Host'),
	(5, 'Coder'),
	(4, 'Super Administrator'),
	(3, 'Primary Administrator'),
	(2, 'Administrator'),
	(1, 'Secondary Administrator');


CREATE TABLE IF NOT EXISTS roundsjoined (
  ckey TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS roundsurvived (
  ckey TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS stats (
  ckey         TEXT PRIMARY KEY NOT NULL,
  deaths       INTEGER NOT NULL DEFAULT 0, --player deaths
  roundsplayed INTEGER NOT NULL DEFAULT 0, --rounds played
  suicides     INTEGER NOT NULL DEFAULT 0, --suicides
  traitorwin   INTEGER NOT NULL DEFAULT 0  --traitor wins
);


-- IDK What this is used for, either.
CREATE TABLE IF NOT EXISTS suggest (
  id       INTEGER PRIMARY KEY ASC,
  userid   INTEGER NOT NULL,
  username TEXT NOT NULL,
  title    TEXT NOT NULL,
  desc     TEXT NOT NULL,
  link     TEXT NOT NULL,
  votes    INTEGER NOT NULL DEFAULT 0
);


CREATE TABLE IF NOT EXISTS traitorbuy (
  type TEXT NOT NULL
);


-- Again, weirdly named columns
CREATE TABLE IF NOT EXISTS traitorlogs (
  CKey        TEXT NOT NULL,
  Objective   TEXT NOT NULL,
  Succeeded   INTEGER NOT NULL,
  Spawned     TEXT NOT NULL,
  Occupation  TEXT NOT NULL,
  PlayerCount INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS traitorlogs_ckey ON traitorlogs (CKey);
CREATE INDEX IF NOT EXISTS traitorlogs_succeeded ON traitorlogs (Succeeded);


CREATE TABLE IF NOT EXISTS unbans (
  ckey       TEXT NOT NULL,
  computerid TEXT NOT NULL,
  ips        TEXT NOT NULL,
  reason     TEXT NOT NULL,
  bannedby   TEXT NOT NULL,
  temp       INTEGER NOT NULL, --0 = perma ban / minutes banned
  minutes    INTEGER NOT NULL,
  timebanned TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS voters (
  username TEXT PRIMARY KEY NOT NULL,
  votes    INTEGER NOT NULL
);


CREATE TABLE IF NOT EXISTS web_log (
  type    TEXT NOT NULL,
  message TEXT NOT NULL,
  bywho   TEXT NOT NULL,
  time    DATETIME NOT NULL
);