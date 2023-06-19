# Exploring the Database and table for further understanding of our data.

SELECT 
    *
FROM
    comments
    LIMIT 10;
    
SELECT 
    *
FROM
    ig_follows
    LIMIT 10;
    
SELECT 
    *
FROM
    likes
    LIMIT 10;    
    
SELECT 
    *
FROM
    photo_tags
    LIMIT 10; 
    
SELECT 
    *
FROM
    photos
    LIMIT 10;
 
SELECT 
    *
FROM
    users;
    LIMIT 10; 
    

# MARKETING 
-- 1) Rewarding Most Loyal Users: Find 5 oldest users 
SELECT 
    *
FROM
    users
ORDER BY created_at ASC
LIMIT 5;

 /* ------------------------------------------------*/
 
-- 2) Remind Inactive Users to Start Posting: User with 0 posts.
SELECT 
    u.username, u.id
FROM
    users u
        LEFT JOIN
    photos p ON u.id = p.user_id
WHERE
    p.user_id IS NULL;

 /* ------------------------------------------------*/

-- 3) Declaring Contest Winner: Most liked photo
SELECT 
    users.id,
    users.username,
    photos.id,
    photos.image_url,
    COUNT(*) AS Total_Likes
FROM photos
INNER JOIN likes on likes.photo_id = photos.id
INNER JOIN users on photos.user_id = users.id
GROUP BY photos.id
ORDER BY Total_Likes DESC
LIMIT 1;

-- 4) Hashtag Researching 
SELECT 
    tags.tag_name, COUNT(tag_name) AS No_of_Time_Tag_Used
FROM
    tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY No_of_Time_Tag_Used DESC
LIMIT 5;

-- 5) Launch AD Campaign
SELECT 
    DAYNAME(created_at) AS Day_of_Week,
    COUNT(created_at) AS Most_registered_Day
FROM
    users
GROUP BY Day_of_Week
ORDER BY Most_registered_Day DESC;

/*--------------------------------------------*/ 
		/* INVESTOR METRICS*/
        
-- 1) User Engagement
SELECT 
    COUNT(id) AS `Total Photos `
FROM
    photos ;
 
 SELECT 
    COUNT(id) AS `Total Users`
FROM
    users;
    
-- AVERAGE Post Made = Total Photos /Total Users
SELECT 
    ((SELECT 
            COUNT(id) AS `Total Photos `
        FROM
            photos) / (SELECT 
            COUNT(id) AS `Total Users`
        FROM
            users)) 
					AS `Average Posts`;

-- 2) Bots And Fake Accouts
SELECT 
    u.id, u.username, COUNT(*) AS `Likes Per User/Person`
FROM
    users u
        INNER JOIN
    likes l ON u.id = l.user_id
GROUP BY l.user_id
HAVING `Likes Per User/Person` = (SELECT 
        COUNT(*)
    FROM
        photos);