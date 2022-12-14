CREATE STREAM "cars-request" (
	"REQUEST_NUM" VARCHAR KEY,
    "USERID" VARCHAR,
    "LASTMOD" VARCHAR,
    "REQUESTTYP_NUM" BIGINT,
    "STATUS_NUM" BIGINT,
    "REQERRTYP_CD" VARCHAR,
    "JOB_NO" BIGINT,
    "REQUEST_PARMS" VARCHAR,
	"REQUEST_DT_START" VARCHAR,
    "REQUEST_DT_END" VARCHAR,
    "REQUEST_MSG" VARCHAR,
    "NUM_SYS_ID" BIGINT,
    "REQUEST_FLG_TRACE" VARCHAR,
	"REQUEST_DT_CREATE" VARCHAR
) WITH (KAFKA_TOPIC = 'cars-request', VALUE_FORMAT = 'JSON', PARTITIONS=3, REPLICAS=2);

CREATE TABLE "cars-topr"(
"NUM_OPR_ID" VARCHAR PRIMARY KEY,
"TXT_OPR_NME_LST" VARCHAR,
"TXT_OPR_ID" VARCHAR
)WITH (KAFKA_TOPIC = 'cars-topr', VALUE_FORMAT = 'JSON', PARTITIONS=3, REPLICAS=2);

CREATE STREAM "cars-unvalidated-tp-request" AS
SELECT
users.NUM_OPR_ID, 
CAST((SPLIT(request.REQUEST_NUM, '.')[1]) AS BIGINT) REQUEST_NUMBER,
CAST((SPLIT(users.NUM_OPR_ID, '.')[1]) AS BIGINT) USERID,
LASTMOD,
request.REQUESTTYP_NUM,
request.STATUS_NUM,
request.REQERRTYP_CD,
request.JOB_NO,
request.REQUEST_PARMS,
REQUEST_DT_START,
REQUEST_DT_END,
request.REQUEST_MSG,
request.NUM_SYS_ID,
request.REQUEST_FLG_TRACE,
REQUEST_DT_CREATE,
CAST((SPLIT((SPLIT(REQUEST_PARMS, '=>')[2]), CHR('\u001f'))[1]) AS BIGINT) BUNIT_NUMBER,
TRIM(SPLIT(users.TXT_OPR_NME_LST, ',')[2]) FIRST_NAME,
TRIM(SPLIT(users.TXT_OPR_NME_LST, ',')[1]) LAST_NAME,
REPLACE(users.TXT_OPR_ID, 'SYSTM', 'gsk.com') TO_MAIL,
(CASE WHEN (request.REQUESTTYP_NUM = 43) THEN 'Trading Partner' ELSE NULL END) TYPE_OF_ACTIVATION_REQUEST
FROM "cars-request" request
LEFT JOIN "cars-topr" users ON users.NUM_OPR_ID = request.USERID 
WHERE request.REQUESTTYP_NUM=43 AND request.STATUS_NUM=329;

CREATE TABLE "cars-tp-warning-validations" (
    "REQUEST_NUMBER" BIGINT PRIMARY KEY,
    "VALIDATIONS" VARCHAR
) WITH (KAFKA_TOPIC = 'cars-tp-warning-validations', VALUE_FORMAT = 'JSON', PARTITIONS=3, REPLICAS=2);

CREATE TABLE "cars-tp-warning-validations-query"
AS SELECT *
FROM "cars-tp-warning-validations";