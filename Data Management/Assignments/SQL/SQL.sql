
-- Question 1 
SELECT first_name, last_name, email, birthdate
FROM user_table
ORDER BY last_name ASC;


--Question 2
SELECT first_name ||' '|| last_name as user_full_name
FROM user_table
WHERE last_name LIKE 'K%'
OR last_name LIKE 'M%'
OR last_name LIKE 'L%'
ORDER BY first_name DESC;


--Question 3
SELECT title, subtitle, upload_date, views, likes
FROM video
WHERE upload_date BETWEEN '01-Jan-20' AND '21-Sep-20'
ORDER BY upload_date DESC;


--Question 4 
SELECT title, subtitle, upload_date, views, likes
FROM video
WHERE upload_date > '01-Jan-20' AND upload_date < '21-Sep-20'
ORDER BY upload_date DESC;


--Question 5 
SELECT  video_id, 
        video_size as video_size_MB,
        likes as Likes_Earned,
        video_length as video_length_sec,
        TRUNC(video_length / 60, 1) as video_length_min
FROM video
ORDER BY Likes_Earned DESC;


--Question 6
SELECT  title, 
        likes as Likes_Earned,
        video_length as video_length_sec,
        TRUNC(video_length / 60, 1) as video_length_min
FROM video
WHERE video_length >= 360
ORDER BY Likes_Earned DESC;


--Question 7 
SELECT  cc_id,
        video_id, 
        likes as Popularity,
        TRUNC(likes / 5000) as Awards,
        upload_date as Post_date
FROM video
WHERE likes > 50000;


--Question 8 
SELECT  cc_username
FROM content_creators c
    LEFT JOIN video v 
    ON c.cc_id = v.cc_id
WHERE likes > 50000;


--Question 9 
SELECT  SYSDATE as today_unformatted,
        TO_CHAR(SYSDATE, 'MM/DD/YYYY') as today_formatted,
        '1000' as likes,
        '.0325' as pay_per_like,
        '10' as pay_per_video,
        (1000 * .0325) as pay_sum,
        (10 + (1000*.0325)) as video_total
FROM dual;


--Question 10
SELECT  video_id,
        title, 
        TO_CHAR(upload_date,'MM/DD/YYYY'),
        likes,
        '.0325' as pay_per_like,
        '10' as pay_per_video,
        (likes * .0325) as pay_sum,
        (10 + (likes * .0325)) as video_total
FROM video
ORDER BY video_total DESC;


--Question 11
SELECT  first_name,
        last_name, 
        birthdate, 
        CC_flag, 
        comment_body
FROM user_table u 
    LEFT JOIN comments c 
    ON u.user_id = c.user_id
ORDER BY LENGTH(comment_body) DESC;


--Question 12
SELECT  u.user_id,
        u.first_name ||' '|| u.last_name as user_name,
        t.topic_id,
        t.topic_name
FROM user_table u
    JOIN user_topic_subsc s
    ON u.user_id = s.user_id
    JOIN topic t 
    ON s.topic_id = t.topic_id
WHERE topic_name = 'SQL';


--Question 13 
SELECT  v.title,
        v.subtitle,
        u.first_name,
        u.last_name, 
        u.CC_flag,
        c.comment_body
FROM user_table u
    JOIN comments c
    ON u.user_id = c.user_id
    JOIN video v
    ON c.video_id = v.video_id
WHERE v.video_id = '100000'
ORDER BY u.last_name;
 
    
--Question 14
SELECT DISTINCT u.first_name,
                u.last_name,
                u.email
FROM user_table u
        LEFT OUTER JOIN comments c
        ON u.user_id = c.user_id
WHERE c.user_id IS NULL
ORDER BY u.last_name;


--Question 15
SELECT  '1-TOP-TIER' as video_tier,
        video_id,
        revenue,
        views
    FROM video
    WHERE views >= 30000
UNION
SELECT  '2-TOP-TIER' as video_tier,
        video_id,
        revenue,
        views
    FROM video
    WHERE views between 20000 AND 29999 
UNION 
SELECT  '3-TOP-TIER' as video_tier,
        video_id,
        revenue,
        views
    FROM video
    WHERE views < 20000;


--Question 16
SELECT  c.cc_username,
        v.revenue
    FROM content_creators c
    JOIN video v
    ON c.cc_id = v.cc_id
ORDER BY v.revenue DESC;
-- Yes ElementarySQL is the most successful in both categories as seen in question 7. 

--Question 17
SELECT DISTINCT u.first_name,
                u.last_name,
                r.card_type
    FROM user_table u
    JOIN content_creators c
    ON u.user_id = c.user_id
    JOIN creditcard r 
    ON c.cc_id = r.contentcreator_id


