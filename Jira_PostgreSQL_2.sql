WITH
    with_1 AS
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project = 00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int NOT IN (00001, 00002, 00003, 00004, 00005)
            GROUP BY table_2."ID") AS issues_with_or
    ),
    with_2 AS
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project = 00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int = 00004 -- Completed
                AND date_trunc('month', jiraissue.resolutiondate)::date = date_trunc('month', CURRENT_DATE)::date
            GROUP BY table_2."ID") AS issues_with_or
    ),
    with_3 AS
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project = 00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int NOT IN (00001, 00002, 00003, 00004, 00005)
                AND (SELECT cfo.customvalue
                        FROM customfieldoption AS cfo
                        INNER JOIN customfieldvalue AS cfv
                            ON cfo.customfield = cfv.customfield
                            AND cfv.issue = jiraissue.id
                            AND cfv.customfield = 00007 -- OR
                        WHERE cfo.id::int = cfv.stringvalue::int) = 'Task Completed'
                AND date_trunc('month', jiraissue.duedate)::date = date_trunc('month', CURRENT_DATE + INTERVAL '1 month')::date -- Deadline specified for the next month
                AND date_trunc('month', jiraissue.updated)::date = date_trunc('month', CURRENT_DATE)::date
            GROUP BY table_2."ID") AS issues_with_or
    ),
    with_4 AS
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project = 00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int NOT IN (00001, 00002, 00003, 00004, 00005)
                AND (date_trunc('month', jiraissue.duedate)::date = date_trunc('month', CURRENT_DATE)::date)
            GROUP BY table_2."ID") AS issues_with_or
    ),
    with_5 AS
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project = 00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int = 00004 -- Completed
                AND (date_trunc('month', jiraissue.duedate)::date = date_trunc('month', CURRENT_DATE)::date)
                AND (date_trunc('month', jiraissue.resolutiondate)::date = date_trunc('month', CURRENT_DATE)::date)
            GROUP BY table_2."ID") AS issues_with_or
    )
SELECT
--//-- Column №1
    (SELECT * FROM with_1) AS column_1,
--//-- Column №2
    (SELECT * FROM with_2) AS column_2,
--//-- Column №3
    (SELECT * FROM with_3) AS column_3,
--//-- Column №4
    (SELECT (((SELECT * FROM with_2) / (SELECT * FROM with_1))::real * 100)) || '%' AS column_4,
--//-- Column №5
    (SELECT (((SELECT * FROM with_3) / (SELECT * FROM with_1))::real * 100)) || '%' AS column_5,
--//-- Column №6
    (SELECT * FROM with_4) AS column_6,
--//-- Column №7
    (SELECT * FROM with_5) AS column_7,
--//-- Column №8
    (SELECT
        CASE
            WHEN
            (SELECT * FROM with_4)::real > 0
                THEN
                (SELECT (((SELECT * FROM with_5) / (SELECT * FROM with_4))::real * 100)) || '%'
            ELSE 0 || '%'
        END) AS column_8,
--//-- Column №9
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project =00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int = 00003 -- Evaluation
                AND
                    (date_trunc('month', MAX(changegroup.created))
                    FROM changegroup
                    INNER JOIN changeitem
                        ON changegroup.id = changeitem.groupid
                    WHERE changeitem.field ='status'
                    AND changegroup.issueid = jiraissue.id)::date = date_trunc('month', CURRENT_DATE)::date -- Status changed in the current month
            GROUP BY table_2."ID") AS issues_with_or) AS column_9,
--//-- Column №10
    (SELECT COUNT("ID")
        FROM
            (SELECT table_2."ID"
                FROM table_2
            INNER JOIN jiraissue
                ON jiraissue.id = table_2."ID"
            WHERE jiraissue.project =00001
                AND jiraissue.issuetype::int = 00002 -- Story
                AND jiraissue.issuestatus::int = 00003 -- Evaluation
            GROUP BY table_2."ID") AS issues_with_or) AS column_10