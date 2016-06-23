DROP DATABASE IF EXISTS trelloanalytics;
CREATE DATABASE trelloanalytics;
USE trelloanalytics;

DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id int(11) NOT NULL AUTO_INCREMENT,
    username varchar(200) NOT NULL DEFAULT '',
    password varchar(200) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE user
    ADD PRIMARY KEY (id);
