--DROP SECTION 
-- This section contains the sequence and table drops with the sequence drops first. 
--The linking tables get dropped first because without the parent tables, the linking tables
--would not exist. These are all dropped so you can run the script over and over again while 
--recreating the everything and having no trouble. 
-- Brett Nesfeder, bmn644


-- sequence drops
DROP SEQUENCE user_id_seq;
DROP SEQUENCE comment_id_seq;
DROP SEQUENCE topic_id_seq;
DROP SEQUENCE card_id_seq;
DROP SEQUENCE video_id_seq;
DROP SEQUENCE content_c_seq;

-- table drops 
DROP TABLE tags;
DROP TABLE subscriptions;
DROP TABLE topic_videos;
DROP TABLE comments;
DROP TABLE card_payment;
DROP TABLE videos;
DROP TABLE content_creator;
DROP TABLE topics;
DROP TABLE browsers;


-- CREATE SECTION
-- This section creates and alters the sequences and tables. The sequences are created first and then 
-- used within the tables while their creation is done. After the tables are created, I alter a couple in 
-- order to ensure email is unique and above 7 characters. 
-- Brett Nesfeder, bmn644


--create user_id sequence 
CREATE SEQUENCE user_id_seq
START WITH 1000000
INCREMENT BY 1
MAXVALUE 9999999;

-- create card_id sequence 
CREATE SEQUENCE card_id_seq
START WITH 1000000
INCREMENT BY 1
MAXVALUE 9999999;

--create topic_id sequence 
CREATE SEQUENCE topic_id_seq
START WITH 1000
INCREMENT BY 1
MAXVALUE 9999;

-- create video_id sequence
CREATE SEQUENCE video_id_seq
START WITH 1000
INCREMENT BY 1
MAXVALUE 9999;

-- create comment_id sequence
CREATE SEQUENCE comment_id_seq
START WITH 1000
INCREMENT BY 1
MAXVALUE 9999;

-- create content_creator sequence
CREATE SEQUENCE content_c_seq
START WITH 1000
INCREMENT BY 1
MAXVALUE 9999;

-- create users table 
CREATE TABLE browsers
(
    user_id             NUMBER       DEFAULT user_id_seq.NEXTVAL  NOT NULL PRIMARY KEY,
    user_first_name     VARCHAR(30)  NOT NULL,
    user_middle_name    VARCHAR(30),
    user_last_name      VARCHAR(40)  NOT NULL,
    todays_date         DATE                    DEFAULT SYSDATE,
    user_birthdate      DATE         NOT NULL,
    user_email          VARCHAR(50)  NOT NULL,
    CC_flag             CHAR(1)                 DEFAULT 'N',
    CONSTRAINT age_check_constraint CHECK (todays_date - user_birthdate > 13)
);

-- create content_creator table 
CREATE TABLE content_creator
(
    cc_id               NUMBER       DEFAULT content_c_seq.NEXTVAL  NOT NULL   primary key,
    cc_phone            CHAR(12)     NOT NULL,
    cc_address          VARCHAR(30)  NOT NULL,
    cc_zip              CHAR(5)      NOT NULL,
    cc_country          VARCHAR(30)  NOT NULL,
    cc_state            CHAR(2)      NOT NULL,
    cc_username         VARCHAR(40)  NOT NULL,
    cc_subscription     VARCHAR(20)  DEFAULT 'FREE'             NOT NULL,
    user_id             NUMBER       NOT NULL,
    CONSTRAINT user_cc_fk               FOREIGN KEY (user_id) REFERENCES browsers(user_id)
);

-- create card_payment table 
CREATE TABLE card_payment
(
    card_id             NUMBER       DEFAULT card_id_seq.NEXTVAL  NOT NULL    primary key,
    cc_id               NUMBER       NOT NULL,
    card_type           VARCHAR(20)  NOT NULL,
    card_exp_date       DATE         NOT NULL,
    card_sec_code       VARCHAR(4)   NOT NULL,
    card_address        VARCHAR(30)  NOT NULL,
    card_city           VARCHAR(30)  NOT NULL,
    card_state          CHAR(2)      NOT NULL,
    card_zip            CHAR(5)      NOT NULL,
    CONSTRAINT cc_card_fk               FOREIGN KEY (cc_id) REFERENCES content_creator(cc_id)
);

-- create videos table
CREATE TABLE videos
(
    video_id            NUMBER       DEFAULT video_id_seq.NEXTVAL   NOT NULL      primary key,
    video_title         VARCHAR(40)  NOT NULL,
    video_subtitle      VARCHAR(75)  NOT NULL,
    video_uploaded      DATE         NOT NULL,
    video_length        NUMBER       NOT NULL, 
    video_size          NUMBER       NOT NULL,
    video_views         NUMBER                      DEFAULT 0,
    video_likes         NUMBER                      DEFAULT 0,
    video_revenue       NUMBER                      DEFAULT 0,
    cc_id               NUMBER,
    CONSTRAINT cc_video_fk              FOREIGN KEY (cc_id) REFERENCES content_creator(cc_id)    
);

-- create topics table
CREATE TABLE topics 
(
    topic_id            NUMBER        DEFAULT topic_id_seq.NEXTVAL    NOT NULL      primary key,
    topic_name          VARCHAR(30)   NOT NULL,
    topic_description   VARCHAR(100)  NOT NULL
);

-- create comments table
CREATE TABLE comments
(
    comment_id          NUMBER         DEFAULT comment_id_seq.NEXTVAL NOT NULL     primary key,
    user_id             NUMBER         NOT NULL,
    video_id            NUMBER         NOT NULL,
    comment_body        VARCHAR(150)   NOT NULL,
    comment_time        DATE           NOT NULL,
    CONSTRAINT user_id_fk               FOREIGN KEY(user_id) REFERENCES browsers(user_id),
    CONSTRAINT video_id_fk              FOREIGN KEY(video_id) REFERENCES videos(video_id)
);

--create tags table
CREATE TABLE tags
(
    cc_id               NUMBER       NOT NULL,
    comment_id          NUMBER       NOT NULL,
    user_id             NUMBER       NOT NULL,
    video_id            NUMBER       NOT NULL,
    CONSTRAINT cc_comment_pck           PRIMARY KEY (cc_id, comment_id),
    CONSTRAINT cc_id_fk                 FOREIGN KEY (cc_id) REFERENCES content_creator(cc_id),
    CONSTRAINT comment_id_fk            FOREIGN KEY (comment_id) REFERENCES comments(comment_id),
    CONSTRAINT user_id_tag_fk           FOREIGN KEY (user_id)    REFERENCES browsers(user_id),
    CONSTRAINT video_id_tag_fk          FOREIGN KEY (video_id)   REFERENCES videos(video_id)
);

-- create topic_videos table
CREATE TABLE topic_videos
(
    video_id            NUMBER      NOT NULL,
    topic_id            NUMBER      NOT NULL,
    CONSTRAINT video_topic_pck          PRIMARY KEY (video_id, topic_id),
    CONSTRAINT video_id_topic_fk        FOREIGN KEY (video_id) REFERENCES videos(video_id),
    CONSTRAINT topic_video_fk           FOREIGN KEY (topic_id) REFERENCES topics(topic_id)
);

-- create subscriptions table
CREATE TABLE subscriptions
(
    user_id             NUMBER        NOT NULL,
    topic_id            NUMBER        NOT NULL,
    CONSTRAINT user_topic_pck          PRIMARY KEY (user_id, topic_id),
    CONSTRAINT user_subs_topic_fk      FOREIGN KEY (user_id) REFERENCES browsers(user_id),
    CONSTRAINT topic_subs_fk           FOREIGN KEY (topic_id) REFERENCES topics(topic_id)
);

-- make email unique
ALTER TABLE browsers
MODIFY user_email UNIQUE;

-- check length of email 
ALTER TABLE browsers
ADD CONSTRAINT email_length_check CHECK (LENGTH(user_email) > 7);


-- INSERT SECTION
-- In this section, I insert data into the newly created tables. The attribute names are called first
-- followed by the values that will be plugged into those attributes. Each section is followed by a 
-- COMMIT in order to ensure that the values are committed to the table. For videos, length
-- of a video is measured in seconds. 
-- Brett Nesfeder, bmn644


-- insert into users table 
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email)
VALUES ('Pat', 'Ted', 'Johnson', TO_DATE('30-MAY-97', 'DD-MON-RR'), 'patedj@gmail.com');
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email, CC_flag)
VALUES ('Mike', '', 'Tyson', TO_DATE('30-JUNE-66', 'DD-MON-RR'), 'fistsoffury@gmail.com', 'Y');
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email, CC_flag)
VALUES ('Karl', '', 'Towns', TO_DATE('10-NOVEMBER-98', 'DD-MON-RR'), 'kat@gmail.com', 'Y');
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email, CC_flag)
VALUES ('Rick', '', 'Sanchez', TO_DATE('15-JULY-60', 'DD-MON-RR'), 'portaldude@gmail.com', 'Y');
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email)
VALUES ('Isabelle', 'Rachel', 'Cooper', TO_DATE('14-JUNE-98', 'DD-MON-RR'), 'beachgirl@gmail.com');
INSERT INTO browsers 
(user_first_name, user_middle_name, user_last_name, user_birthdate,user_email, CC_flag)
VALUES ('Michael', '', 'Scott', TO_DATE('09-JUNE-75', 'DD-MON-RR'), 'paperonpaper@gmail.com', 'Y');

COMMIT;

-- insert into content creators
INSERT INTO content_creator
(cc_phone, cc_address, cc_zip, cc_country, cc_state, cc_username, cc_subscription, user_id)
VALUES('155590972723', '111 Muscle Lane', '30198', 'United States of America', 'TX', 'bigmike1234','BUSINESS','1000001');
INSERT INTO content_creator
(cc_phone, cc_address, cc_zip, cc_country, cc_state, cc_username, user_id)
VALUES('171898099981', '32 Wolves Drive', '90912', 'United States of America', 'MN', 'kittykat32','1000002');
INSERT INTO content_creator
(cc_phone, cc_address, cc_zip, cc_country, cc_state, cc_username, cc_subscription, user_id)
VALUES('123400001234', '21 Glarb Road', '09201', 'United States of America', 'WA', 'kingoftheworld98','GENERAL','1000003');
INSERT INTO content_creator
(cc_phone, cc_address, cc_zip, cc_country, cc_state, cc_username, user_id)
VALUES('169017178012', '1738 Paper Avenue', '31501', 'United States of America', 'PA', 'prisonmike15','1000005');

COMMIT;


-- insert credit cards
INSERT INTO card_payment
(cc_id, card_type, card_exp_date, card_sec_code, card_address, card_city, card_state,card_zip)
VALUES('1002', 'Visa', TO_DATE('30-JANUARY-22', 'DD-MON-RR'), '999', '21 Glarb Road', 'Seattle', 'WA', '09201');
INSERT INTO card_payment
(cc_id, card_type, card_exp_date, card_sec_code, card_address, card_city, card_state,card_zip)
VALUES('1002', 'Discover', TO_DATE('15-DECEMBER-23', 'DD-MON-RR'), '777', '21 Glarb Road', 'Seattle', 'WA', '09201');
INSERT INTO card_payment
(cc_id, card_type, card_exp_date, card_sec_code, card_address, card_city, card_state,card_zip)
VALUES('1003', 'Visa', TO_DATE('10-MARCH-22', 'DD-MON-RR'), '304', '1738 Paper Avenue', 'Scranton', 'PA', '31501');
INSERT INTO card_payment
(cc_id, card_type, card_exp_date, card_sec_code, card_address, card_city, card_state,card_zip)
VALUES('1001', 'American Express', TO_DATE('12-APRIL-23', 'DD-MON-RR'), '003', '32 Wolves Drive', 'Minneapolis', 'MN', '90912');

COMMIT;


-- creating four videos
INSERT INTO videos
(video_title, video_subtitle, video_uploaded, video_length, video_size, video_views, video_likes, video_revenue, cc_id)
VALUES('How to Make a Portal Gun', 'This video is about making a portal gun that leads to different dimensions.', 
TO_DATE('20/12/2019 17:30:10','DD/MM/YYYY HH24:MI:SS'), '457', '40', '102','34','125', '1002');
INSERT INTO videos
(video_title, video_subtitle, video_uploaded, video_length, video_size, video_views, video_likes, video_revenue, cc_id)
VALUES('How to Bite an Ear in a Boxing Match', 'This video shows how to bite a chunk out of your opponents ear.', 
TO_DATE('12/01/2020 19:20:00','DD/MM/YYYY HH24:MI:SS'), '300', '30', '10000202','3939','1200', '1000');
INSERT INTO videos
(video_title, video_subtitle, video_uploaded, video_length, video_size, video_views, video_likes, video_revenue, cc_id)
VALUES('Dope Skate Tricks', 'Just me doing some dope skate tricks.', TO_DATE('12/03/2020 10:25:12','DD/MM/YYYY HH24:MI:SS'), 
'230', '35', '2001001','34002','30300', '1001');
INSERT INTO videos
(video_title, video_subtitle, video_uploaded, video_length, video_size, cc_id)
VALUES('Making Paper', 'Showing you all how to make paper.', TO_DATE('15/09/2020 11:32:45', 'DD/MM/YYYY HH24:MI:SS'), '780', '42', '1003');

COMMIT;


-- create four comments
INSERT INTO comments
(user_id, video_id, comment_body, comment_time)
VALUES('1000000', '1002', 'Yo man! Those ARE some pretty dope tricks!', TO_DATE('12/04/2020 13:31:45', 'DD/MM/YYYY HH24:MI:SS')); 
INSERT INTO comments
(user_id, video_id, comment_body, comment_time)
VALUES('1000004', '1000', 'I have always wondered how to do this. Awesome!', TO_DATE('10/05/2020 10:12:05', 'DD/MM/YYYY HH24:MI:SS'));
INSERT INTO comments
(user_id, video_id, comment_body, comment_time)
VALUES('1000005', '1001', 'WOW! That is so violent!', TO_DATE('23/08/2020 20:20:20', 'DD/MM/YYYY HH24:MI:SS')); 
INSERT INTO comments
(user_id, video_id, comment_body, comment_time)
VALUES('1000000', '1003', 'This is very informative. I wish I was a content creator.', TO_DATE('02/09/2020 23:31:40', 'DD/MM/YYYY HH24:MI:SS'));

COMMIT;


-- INDEX SECTION 
-- This section indexes a couple columns. I chose these columns because they will mostly be filled
-- with unique values and could potentially be queried frequently. 
-- Brett Nesfeder, bmn644


-- create indexes
CREATE INDEX video_sub_idx
ON videos (video_subtitle);

CREATE INDEX title_idx
ON videos (video_title);










    



