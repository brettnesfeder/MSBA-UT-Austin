-- Question 1 
SELECT
    COUNT(DISTINCT(c.cc_id)) as Total_CCs,
    MIN(v.video_length) as Min_Video_Length,
    MAX(v.video_length) as Max_Video_Length,
    MAX(v.views)as Max_Views
FROM content_creators c
LEFT JOIN video v ON c.cc_id = v.cc_id;



--Question 2
SELECT  COUNT(c.comment_id) as Number_Of_Comments, 
        MAX(c.time_date) as Comment_Date, 
        v.title as Title
FROM video v 
JOIN comments c ON v.video_id = c.video_id
GROUP BY v.title
ORDER BY MAX(c.time_date) ASC;



--Question 3
SELECT  COUNT(DISTINCT(c.cc_id)) as Content_Creators,
        c.city as CITY,
        ROUND(AVG(v.likes)) as Average_Likes_Per_Video
FROM content_creators c
LEFT JOIN video v ON c.cc_id = v.cc_id
GROUP BY c.city
ORDER BY ROUND(AVG(v.likes)) DESC;



--Question 4
SELECT  t.topic_id as TOPIC_ID,
        t.topic_name as TOPIC_NAME,
        ROUND(AVG(TO_NUMBER(REPLACE(v.video_size, 'MB', ''))), 2) as AVERAGE_VIDEO_SIZE,
        SUM(v.likes) as TOTAL_LIKES
FROM topic t
LEFT JOIN video_topic_link l ON t.topic_id = l.topic_id
LEFT JOIN video v ON l.video_id = v.video_id
GROUP BY t.topic_id, t.topic_name
ORDER BY ROUND(AVG(TO_NUMBER(REPLACE(v.video_size, 'MB', ''))), 2) DESC;
     


--Question 4b
SELECT  t.topic_id as TOPIC_ID,
        t.topic_name as TOPIC_NAME,
        AVG(TO_NUMBER(REPLACE(v.video_size, 'MB', ''))) OVER(PARTITION BY topic_name) as AVERAGE_VIDEO_SIZE,
        SUM(v.likes) OVER(PARTITION BY topic_name) as TOTAL_LIKES
FROM video v
JOIN video_topic_link l ON v.video_id = l.video_id
JOIN topic t  ON l.topic_id = t.topic_id;
  


--Question 5
SELECT  u.first_name,
        u.last_name, 
        TRUNC((SUM(v.views) - 100)/ 5000) as awards_earned
FROM video v 
JOIN content_creators c ON v.cc_id = c.cc_id
JOIN user_table u ON c.user_id = u.user_id
GROUP BY u.first_name, u.last_name
HAVING TRUNC((SUM(v.views) - 100)/ 5000) > 10
ORDER BY awards_earned DESC;



--Question 6a
SELECT  u.first_name,
        c.city_billing,
        c.state_billing,
        COUNT(c.card_id)
FROM user_table u 
JOIN content_creators r ON u.user_id = r.user_id
JOIN creditcard c ON r.cc_id = c.contentcreator_id
WHERE c.state_billing IN ('TX', 'NY')
GROUP BY ROLLUP(u.first_name,c.city_billing, c.state_billing)
ORDER BY c.city_billing ;



--Question 6b
--The ROLLUP operator gives subtotals for specified columns as well as a grand total.
--The CUBE operator differs in that it calculates a subtotal for every possible 
-- dimension. This can be helpful for cross tabular studies.



--Question 7 
SELECT  a.contentcreator_id,
        a.card_id,
        c.street_address ||' ' || c.city || ' ' || c.state || ' ' || c.zip_code as billing_address,
        'Y' as flag
FROM creditcard a
JOIN content_creators c ON a.contentcreator_id = c.cc_id
WHERE a.card_id IN ('100000','100001','100002','100007')
UNION
SELECT  a.contentcreator_id,
        a.card_id,
        c.street_address ||' ' || c.city || ' ' || c.state || ' ' || c.zip_code as billing_address,
        'N' as flag
FROM creditcard a
JOIN content_creators c ON a.contentcreator_id = c.cc_id
WHERE a.card_id IN ('100003','100004','100005','100006');



--Question 8a
SELECT  v.cc_id,
        COUNT(DISTINCT(v.video_id)) AS number_of_videos,
        COUNT(DISTINCT(t.topic_id)) AS number_of_topics
FROM video v
LEFT JOIN video_topic_link l ON v.video_id = l.video_id
LEFT JOIN topic t ON l.topic_id = t.topic_id
GROUP BY v.cc_id
HAVING COUNT(DISTINCT(t.topic_id)) > 1
ORDER BY v.cc_id DESC;



--Question 8b
SELECT  DISTINCT(v.cc_id),
        COUNT(DISTINCT(v.video_id)) OVER(PARTITION BY v.cc_id) AS number_of_videos,
        COUNT(DISTINCT(t.topic_id)) OVER(PARTITION BY v.cc_id) AS number_of_topics
FROM video v
LEFT JOIN video_topic_link l ON v.video_id = l.video_id
LEFT JOIN topic t ON l.topic_id = t.topic_id
ORDER BY v.cc_id DESC;



--Question 9 
SELECT DISTINCT topic_name 
FROM topic
WHERE topic_id IN (SELECT topic_id FROM video_topic_link)
ORDER BY topic_name DESC;



--Question 10
--SELECT AVG(likes) FROM video - 48210
SELECT  u.user_id,
        v.video_id,
        v.likes
FROM content_creators u 
JOIN video v ON u.cc_id = v.cc_id
WHERE v.likes IN (SELECT v.likes FROM video WHERE v.likes > 48210)
ORDER BY v.likes DESC;



--Question 11
SELECT  u.first_name,
        u.last_name,
        u.email, 
        u.cc_flag, 
        u.birthdate
FROM user_table u 
JOIN (SELECT u.user_id, COUNT(video_id)
      FROM video v
      JOIN content_creators c ON v.cc_id = c.cc_id
      FULL JOIN user_table u ON c.user_id = u.user_id
      GROUP BY u.user_id, c.cc_id
      HAVING COUNT(video_id) = 0)
      nv ON u.user_id = nv.user_id
WHERE u.cc_flag = 'Y';



--Question 12
SELECT  title,
        subtitle,
        video_size, 
        views,
        number_of_comments
FROM video v 
JOIN (SELECT video_id, COUNT(comment_id) as number_of_comments
      FROM comments
      GROUP BY video_id
      HAVING COUNT(comment_id) > 1) c
      ON v.video_id = c.video_id
ORDER BY number_of_comments DESC;



--Question 13 
SELECT  u.user_id,
        u.first_name, 
        u.last_name, 
        number_of_videos
FROM user_table u 
LEFT JOIN (SELECT u.user_id, COUNT(v.video_id) as number_of_videos
           FROM video v 
           JOIN content_creators c ON v.cc_id = c.cc_id
           JOIN user_table u ON c.user_id = u.user_id
           GROUP BY u.user_id) l
           ON u.user_id = l.user_id;



--Question 14 
SELECT  c.cc_id, 
        c.cc_username, 
        days_since_last_upload
FROM content_creators c 
LEFT JOIN (SELECT c.cc_id, ROUND(SYSDATE - MAX(upload_date)) as days_since_last_upload
           FROM video v 
           JOIN content_creators c ON v.cc_id = c.cc_id
           GROUP BY c.cc_id) l 
           ON c.cc_id = l.cc_id
        
        