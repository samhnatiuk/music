CREATE SCHEMA `music`;

CREATE TABLE music.Accounts (
	AccountID int NOT NULL AUTO_INCREMENT,
    Email varchar(100) NOT NULL,
    PRIMARY KEY(AccountID)
);

CREATE TABLE music.Artist (
	ArtistID int NOT NULL AUTO_INCREMENT,
    Name_ varchar(100),
    Country varchar(100),
    AccountID int NULL,
    PRIMARY KEY(ArtistID),
    FOREIGN KEY(AccountID) REFERENCES music.Accounts(AccountID)
);

CREATE TABLE music.Users (
	UserID int NOT NULL AUTO_INCREMENT,
    Name_ varchar(100),
    Country varchar(100),
    AccountID int NULL,
    PRIMARY KEY(UserID),
    FOREIGN KEY(AccountID) REFERENCES music.Accounts(AccountID)
);

CREATE TABLE music.Follow (
	UserID int,
    ArtistID int,
    PRIMARY KEY(UserID, ArtistID),
    FOREIGN KEY(UserID) REFERENCES music.Users(UserID),
    FOREIGN KEY(ArtistID) REFERENCES music.Artist(ArtistID)
);

CREATE TABLE music.Song (
	SongID int NOT NULL AUTO_INCREMENT,
    Name_ varchar(100),
    Duration int,
    PRIMARY KEY(SongID)
);

CREATE TABLE music.PerformsOnSong (
	SongID int,
	ArtistID int,
    PRIMARY KEY(ArtistID, SongID),
    FOREIGN KEY(ArtistID) REFERENCES music.Artist(ArtistID),
    FOREIGN KEY(SongID) REFERENCES music.Song(SongID)
);

CREATE TABLE music.Album (
	AlbumID int NOT NULL AUTO_INCREMENT,
    Title varchar(100),
    MainArtist int NULL,
    PRIMARY KEY(AlbumID),
    FOREIGN KEY (MainArtist) REFERENCES music.Artist(ArtistID)
);

CREATE TABLE music.AlbumTrack (
	AlbumID int,
    TrackNo int,
    SongID int,
    PRIMARY KEY(AlbumID, TrackNo),
    FOREIGN KEY(AlbumID) REFERENCES music.Album(AlbumID),
    FOREIGN KEY(SongID) REFERENCES music.Song(SongID)
);

CREATE TABLE music.Playlist (
	PlaylistID int NOT NULL AUTO_INCREMENT,
    Title varchar(100),
    UserID int NOT NULL,
    PRIMARY KEY(PlaylistID),
    FOREIGN KEY(UserID) REFERENCES music.Users(UserID)
);

CREATE TABLE music.PlaylistTrack (
	PlaylistID int,
    TrackNo int,
    SongID int,
    PRIMARY KEY(PlaylistID, TrackNo),
    FOREIGN KEY(PlaylistID) REFERENCES music.Playlist(PlaylistID),
    FOREIGN KEY(SongID) REFERENCES music.Song(SongID)
);
    
    
