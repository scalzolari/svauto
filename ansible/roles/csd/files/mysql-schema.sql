-- Copyright 2014 Sandvine Incorporated ULC.  All rights reserved.
-- Use of this source code is governed by a license that can be
-- found in the LICENSE file.

-- run:
-- sudo mysql < mysql-schema.sql

drop database if exists cs;

create database cs character set utf8 collate utf8_unicode_ci;

grant all privileges on cs.* to 'svadmin'@'localhost' identified by 'sandvine';

use cs;

create table pair (
	name varchar(128),
	value varchar(128),

	primary key(name)
);
