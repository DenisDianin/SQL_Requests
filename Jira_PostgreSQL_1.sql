SELECT
--//-- Column №1
    'Task-' || jiraissue.issuenum AS Column_1,
--//-- Column №2
    jiraissue.summary AS Column_2,
--//-- Column №3
    (SELECT priority.pname
        FROM priority
        WHERE priority.id = jiraissue.priority) AS Column_3,
--//-- Column №4
    (SELECT cwd_user.display_name
        FROM customfieldvalue AS cfv
     INNER JOIN cwd_user
        ON cfv.stringvalue = cwd_user.user_name
     WHERE cfv.issue = jiraissue.id
     AND cfv.customfield = 10001) AS Column_4,
--//-- Column №5
    (SELECT cfo.customvalue
        FROM customfieldoption AS cfo
        WHERE cfo.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10002)::int) AS Column_5,
--//-- Column №6
    FRes."ResultString" AS Column_6,
--//-- Column №7
    (SELECT issuestatus.pname
        FROM issuestatus
        WHERE issuestatus.id = jiraissue.issuestatus) AS Column_7,
--//-- Column №8
    (SELECT
        CASE
            WHEN (ORes.customvalue = 'OResult_1'
                AND jiraissue.issuestatus::int IN (00001, 00002, 00003, 00004, 00005, 00006, 00007, 00008, 00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue = 'OResult_2'
                AND jiraissue.issuestatus::int IN (00002, 00003, 00004, 00005, 00006, 00007, 00008, 00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue = 'OResult_3'
                AND jiraissue.issuestatus::int IN (00006, 00007, 00008, 00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue ='OResult_4'
                AND jiraissue.issuestatus::int IN (00007, 00008, 00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue ='OResult_5'
                AND jiraissue.issuestatus::int IN (00008, 00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue ='OResult_6'
                AND jiraissue.issuestatus::int IN (00009, 00010))
                THEN 'Reached'
            WHEN (ORes.customvalue = 'OResult_7'
                AND jiraissue.issuestatus::int = 00010)
                THEN 'Reached'
            ELSE 'Unreached'
        END
        FROM customfieldoption AS ORes
        WHERE ORes.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10003)::int) AS Column_8,
--//-- Column №9
    jiraissue.created::date AS Column_9,
--//-- Column №10
    jiraissue.duedate::date AS Column_10,
--//-- Column №11
    (SELECT MAX(changegroup.created)::date
        FROM changegroup
        INNER JOIN changeitem
            ON changegroup.id = changeitem.groupid
        WHERE changeitem.field = 'status'
        AND changegroup.issueid = jiraissue.id) AS Column_11,
--//-- Column №12
    (SELECT cfo.customvalue
        FROM customfieldoption AS cfo
        WHERE cfo.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10004)::int) AS Column_12,
--//-- Column №13
    (SELECT cfo.customvalue
        FROM customfieldoption AS cfo
        WHERE cfo.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10005)::int) AS Column_13,
--//-- Column №14
    (SELECT cfo.customvalue
        FROM customfieldoption AS cfo
        WHERE cfo.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10006)::int) AS Column_14,
--//-- Column №15
    (SELECT SUM(jdi.timeoriginalestimate/3600)::real
        FROM jiraissue AS jpi -- Parental task
        INNER JOIN issuelink AS il
            ON il.source = jiraissue.id
        INNER JOIN issuelinktype AS ilt
            ON ilt.id = il.linktype
            AND ilt.pstyle = 'jira_subtask'
        INNER JOIN jiraissue AS jdi -- Child tasks
            ON jdi.id = il.destination
        WHERE jpi.id = jiraissue.id) || ' h' AS Column_15,
--//-- Column №16
    (SELECT cfo.customvalue
        FROM customfieldoption AS cfo
        WHERE cfo.id::int = (SELECT cfv.stringvalue
                                FROM customfieldvalue AS cfv
                                WHERE cfv.issue = jiraissue.id
                                AND cfv.customfield = 10007)::int) AS Column_16,
--//-- Column №17
    (SELECT ci.newstring
        FROM changegroup AS cg
        INNER JOIN changeitem AS ci
            ON cg.id = ci.groupid
        WHERE cg.issueid = jiraissue.id
        AND ci.field = 'Risk comments'
        ORDER BY cg.created DESC
        LIMIT 1) AS Column_17,
--//-- Column №18
    (SELECT MAX(cg.created)::date
        FROM changegroup AS cg
        INNER JOIN changeitem ci
            ON cg.id = ci.groupid
        WHERE cg.issueid = jiraissue.id
        AND ci.field = 'Risk') AS Column_18,
--//-- Column №19
    (SELECT MAX(cg.created)::date
        FROM changegroup AS cg
        INNER JOIN changeitem AS ci
            ON cg.id = ci.groupid
        WHERE cg.issueid = jiraissue.id
        AND ci.field = 'Risk comments') AS Column_19,
--//-- Column №20
    (SELECT cwd_user.display_name
        FROM cwd_user
        WHERE cwd_user.user_name = jiraissue.reporter) AS Column_20,
--//-- Column №21
    (SELECT string_agg(c.cname, ', ')
        FROM component AS c
        INNER JOIN nodeassociation AS na
            ON na.sink_node_id = c.id
        WHERE na.source_node_id = jiraissue.id) AS Column_21,
--//-- Column №22
    (SELECT cwd_user.display_name
        FROM cwd_user
        WHERE cwd_user.user_name = jiraissue.assignee) AS Column_22
FROM jiraissue
LEFT JOIN table_2 AS FRes
    ON FRes."ID" = jiraissue.id
    AND FRes."Month" = date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date
    AND FRes."CreatedData" = (SELECT MAX(CDRes."CreatedData")
                                FROM veb_expectedresult AS CDRes
                                WHERE CDRes."ID" = FRes."ID"
                                AND CDRes."Month" = FRes."Month")
WHERE jiraissue.project =00000
    AND jiraissue.issuetype = '00000'
    AND (SELECT cfv.stringvalue
            FROM customfieldvalue AS cfv
            WHERE cfv.issue = jiraissue.id
            AND cfv.customfield = 10008) IS NOT NULL
    AND jiraissue.issuestatus::int NOT IN (00001, 00002, 00003, 00004)
    AND (jiraissue.resolutiondate IS NULL
        OR jiraissue.resolutiondate::date > (CURRENT_DATE::date - INTERVAL '1 month')::date)