SET client_encoding = 'UNICODE';
SET SESSION AUTHORIZATION 'postgres';

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;

SET SESSION AUTHORIZATION 'kupengahao';
SET search_path = public, pg_catalog;


CREATE TABLE matapunauser (
    matapunauserid SERIAL PRIMARY KEY,
    matapunauser character(8),
    "password" character(16),
    matapunauserfullname character varying(255),
    canupdate boolean,
    editor boolean,
    matapunauseremail character varying(255),
    lang character varying(8),
    workflowschemeid integer,
    qa2 boolean DEFAULT false,
    qa3 boolean DEFAULT false,
    sysadmin boolean DEFAULT false
);

REVOKE ALL ON TABLE matapunauser FROM PUBLIC;
GRANT ALL ON TABLE matapunauser TO kupengahao;


CREATE TABLE headword (
    headwordid SERIAL PRIMARY KEY,
    headword text,
    variantno integer,
    majsense text,
    minsense text,
    wordclassid integer,
    definition text,
    example text,
    examplesource text,
    examplesourceid integer,
    examplesourceinfo text,
    synonyms text,
    english text,
    essay text,
    binomial text,
    editorialcomments text,
    createuserid integer,
    createdate timestamp with time zone,
    updateuserid integer,
    updatedate timestamp with time zone,
    owneruserid integer,
    categoryid integer,
    mastersynonymheadwordid integer,
    qastatus1 integer DEFAULT 1,
    definingvocab boolean,
    qastatus2 integer DEFAULT 1,
    collateseq text,
    invisible boolean DEFAULT false,
    isvariant boolean DEFAULT false,
    borrowedlangid integer DEFAULT 1,
    wcs1 boolean DEFAULT false,
    wcs2 boolean DEFAULT false,
    wcs3 boolean DEFAULT false,
    wcs4 boolean DEFAULT false,
    wcs5 boolean DEFAULT false,
    wcs6 boolean DEFAULT false,
    wcs7 boolean DEFAULT false,
    wcs8 boolean DEFAULT false,
    wcs9 boolean DEFAULT false,
    wcs10 boolean DEFAULT false,
    wcs11 boolean DEFAULT false,
    wcs12 boolean DEFAULT false,
    wcs13 boolean DEFAULT false,
    wcs14 boolean DEFAULT false,
    wcs15 boolean DEFAULT false,
    wcs16 boolean DEFAULT false,
    domainid integer DEFAULT 1,
    suffix1 text,
    suffix2 text,
    qastatus3 integer DEFAULT 1,
    sentbyuserid integer,
    workqueueposition integer,
    allocateduserid integer,
    usage1 boolean DEFAULT false,
    usage2 boolean DEFAULT false,
    usage3 boolean DEFAULT false,
    usage4 boolean DEFAULT false,
    usage5 boolean DEFAULT false,
    usage6 boolean DEFAULT false,
    usage7 boolean DEFAULT false,
    usage8 boolean DEFAULT false,
    usage9 boolean DEFAULT false,
    usage10 boolean DEFAULT false,
    usage11 boolean DEFAULT false,
    usage12 boolean DEFAULT false,
    usage13 boolean DEFAULT false,
    usage14 boolean DEFAULT false,
    usage15 boolean DEFAULT false,
    usage16 boolean DEFAULT false,
    mastervariantheadwordid integer,
    masterderivingheadwordid integer,
    source text,
    gloss text,
    relatedterms text,
    detailedexplanation text,
    symbol text
);

REVOKE ALL ON TABLE headword FROM PUBLIC;
GRANT ALL ON TABLE headword TO kupengahao;


CREATE TABLE activityjournal (
    activityjournalid SERIAL PRIMARY KEY,
    activitydate timestamp with time zone,
    matapunauserid integer,
    verb text,
    object text,
    description text
);

REVOKE ALL ON TABLE activityjournal FROM PUBLIC;
GRANT ALL ON TABLE activityjournal TO kupengahao;


CREATE VIEW progresstoday AS
    SELECT matapunauser.matapunauser, count(headword.headword) AS entries_created FROM matapunauser, headword WHERE ((matapunauser.matapunauserid = headword.createuserid) AND ((headword.createdate > timestamptz(date('now'::text))) OR (headword.updatedate > timestamptz(date('now'::text))))) GROUP BY matapunauser.matapunauser;
    
REVOKE ALL ON progresstoday FROM PUBLIC;
GRANT ALL ON progresstoday TO kupengahao;


CREATE TABLE category (
    categoryid SERIAL PRIMARY KEY,
    category text,
    symbol text
);

REVOKE ALL ON category FROM PUBLIC;
GRANT ALL ON category TO kupengahao;


CREATE TABLE examplesource (
    examplesourceid SERIAL PRIMARY KEY,
    examplesource text,
    examplesourcenotes text,
    symbol text
);

REVOKE ALL ON examplesource FROM PUBLIC;
GRANT ALL ON examplesource TO kupengahao;

CREATE TABLE hwarchive (
    headwordid integer,
    headword  text,
    variantno integer,
    majsense text,
    minsense text,
    wordclassid integer,
    definition text,
    example text,
    examplesource text,
    examplesourceid integer,
    examplesourceinfo text,
    synonyms text,
    english text,
    essay text,
    binomial text,
    editorialcomments text,
    createuserid integer,
    createdate timestamp with time zone,
    updateuserid integer,
    updatedate timestamp with time zone,
    owneruserid integer,
    categoryid integer,
    mastersynonymheadwordid integer,
    qastatus1 integer DEFAULT 1,
    definingvocab boolean,
    qastatus2 integer DEFAULT 1,
    collateseq text,
    invisible boolean DEFAULT false,
    isvariant boolean DEFAULT false,
    borrowedlangid integer DEFAULT 1,
    wcs1 boolean DEFAULT false,
    wcs2 boolean DEFAULT false,
    wcs3 boolean DEFAULT false,
    wcs4 boolean DEFAULT false,
    wcs5 boolean DEFAULT false,
    wcs6 boolean DEFAULT false,
    wcs7 boolean DEFAULT false,
    wcs8 boolean DEFAULT false,
    wcs9 boolean DEFAULT false,
    wcs10 boolean DEFAULT false,
    wcs11 boolean DEFAULT false,
    wcs12 boolean DEFAULT false,
    wcs13 boolean DEFAULT false,
    wcs14 boolean DEFAULT false,
    wcs15 boolean DEFAULT false,
    wcs16 boolean DEFAULT false,
    domainid integer DEFAULT 1,
    suffix1 text,
    suffix2 text,
    qastatus3 integer DEFAULT 1,
    sentbyuserid integer,
    workqueueposition integer,
    allocateduserid integer,
    usage1 boolean DEFAULT false,
    usage2 boolean DEFAULT false,
    usage3 boolean DEFAULT false,
    usage4 boolean DEFAULT false,
    usage5 boolean DEFAULT false,
    usage6 boolean DEFAULT false,
    usage7 boolean DEFAULT false,
    usage8 boolean DEFAULT false,
    usage9 boolean DEFAULT false,
    usage10 boolean DEFAULT false,
    usage11 boolean DEFAULT false,
    usage12 boolean DEFAULT false,
    usage13 boolean DEFAULT false,
    usage14 boolean DEFAULT false,
    usage15 boolean DEFAULT false,
    usage16 boolean DEFAULT false,
    mastervariantheadwordid integer,
    masterderivingheadwordid integer,
    source text,
    gloss text,
    relatedterms text,
    detailedexplanation text,
    symbol text,
    hwarchiveid SERIAL PRIMARY KEY,
    archiveuserid integer,
    archivedate timestamp with time zone
);

REVOKE ALL ON hwarchive FROM PUBLIC;
GRANT ALL ON hwarchive TO kupengahao;


CREATE VIEW progress_today_created AS
    SELECT matapunauser.matapunauser, count(headword.headword) AS entries_created FROM matapunauser, headword WHERE ((matapunauser.matapunauserid = headword.createuserid) AND (headword.createdate > timestamptz(date('now'::text)))) GROUP BY matapunauser.matapunauser;

REVOKE ALL ON progress_today_created FROM PUBLIC;
GRANT ALL ON progress_today_created TO kupengahao;


CREATE VIEW progress_today_updated AS
    SELECT matapunauser.matapunauser, count(headword.headword) AS entries_updated FROM matapunauser, headword WHERE ((matapunauser.matapunauserid = headword.updateuserid) AND (headword.updatedate > timestamptz(date('now'::text)))) GROUP BY matapunauser.matapunauser;

REVOKE ALL ON progress_today_updated FROM PUBLIC;
GRANT ALL ON progress_today_updated TO kupengahao;

    
CREATE TABLE qastatus (
    qastatusid serial PRIMARY KEY,
    qastatus character varying(255)
);

REVOKE ALL ON qastatus FROM PUBLIC;
GRANT ALL ON qastatus TO kupengahao;


CREATE TABLE wordclass (
    wordclassid serial PRIMARY KEY,
    wordclass text,
    symbol text,
    canbesecondary boolean
);

REVOKE ALL ON wordclass FROM PUBLIC;
GRANT ALL ON wordclass TO kupengahao;

CREATE TABLE "domain" (
    domainid SERIAL PRIMARY KEY,
    "domain" text,
    symbol text
);

REVOKE ALL ON domain FROM PUBLIC;
GRANT ALL ON domain TO kupengahao;


CREATE TABLE borrowedlang (
    borrowedlangid serial PRIMARY KEY,
    borrowedlang text
);

REVOKE ALL ON borrowedlang FROM PUBLIC;
GRANT ALL ON borrowedlang TO kupengahao;


CREATE TABLE workflowscheme (
    workflowschemeid serial PRIMARY KEY,
    nickname text,
    description text,
    workflowscheme text
);

REVOKE ALL ON workflowscheme FROM PUBLIC;
GRANT ALL ON workflowscheme TO kupengahao;


CREATE TABLE "usage" (
    usageid serial PRIMARY KEY,
    "usage" text,
    symbol text
);

REVOKE ALL ON "usage" FROM PUBLIC;
GRANT ALL ON "usage" TO kupengahao;


CREATE TABLE editorialcomment (
    editorialcommentid serial PRIMARY KEY,
    headwordid integer,
    matapunauserid integer,
    editorialcommentdate timestamp without time zone,
    editorialcomment text
);

REVOKE ALL ON editorialcomment FROM PUBLIC;
GRANT ALL ON editorialcomment TO kupengahao;


CREATE TABLE tag (
    tagid serial PRIMARY KEY,
    tag text
);

REVOKE ALL ON tag FROM PUBLIC;
GRANT ALL ON tag TO kupengahao;


CREATE TABLE headwordtag (
    headwordtagid serial PRIMARY KEY,
    headwordid integer,
    tagid integer
);

REVOKE ALL ON headwordtag FROM PUBLIC;
GRANT ALL ON headwordtag TO kupengahao;


COPY matapunauser (matapunauserid, matapunauser, "password", matapunauserfullname, canupdate, editor, matapunauseremail, lang, workflowschemeid, qa2, qa3) FROM stdin;
2	guest   	guest           	Anonymous Guest	f	f	\N	en	10	f	f
3	importer	glorp           	Import Script	f	f	\N	en	10	f	f
1	dave    	swordfish       	Dave Moskovitz	t	t	dave@thinktank.co.nz	en	10	f	f
49	ian     	uywemncv        	Ian Christensen	t	t	ian@kupengahao.co.nz	en	1	t	t
\.

SELECT setval('matapunauser_matapunauserid_seq',49);

COPY qastatus (qastatusid, qastatus) FROM stdin;
1	__mlmsg_qastatus_1000_notreviewed__
2	__mlmsg_qastatus_1100_deferred__
3	__mlmsg_qastatus_1200_kill__
4	__mlmsg_qastatus_1300_reject__
5	__mlmsg_qastatus_1400_passed__
6	__mlmsg_qastatus_1350_hold_2nd_edition__
\.

SELECT setval('qastatus_qastatusid_seq',6);

COPY wordclass (wordclassid, wordclass, symbol, canbesecondary) FROM stdin;
1	__mlmsg_wc_noun_common__	tin	t
2	__mlmsg_wc_verb_transitive__	tmw	t
3	__mlmsg_wc_verb_intransitive__	tmp	t
4	__mlmsg_wc_adjective__	tāh	t
5	__mlmsg_wc_adverb__	tkē	t
6	__mlmsg_wc_verb_stative__	tmo	t
7	__mlmsg_wc_noun_locative_time__	twā	f
13	__mlmsg_wc_phrase__	kīa	f
14	__mlmsg_wc_partdeterm__	pmu	f
9	__mlmsg_wc_noun_pronoun__	tkp	f
15	__mlmsg_wc_noun_personal__	tit	f
16	__mlmsg_wc_fixedexpr__	kīp	f
8	__mlmsg_wc_noun_locative_place__	twh	f
10	__mlmsg_wc_conjunction__	thn	f
11	__mlmsg_wc_numeral__	tta	f
12	__mlmsg_wc_negative__	tkh	f
17	__mlmsg_wc_interrogative__	tpt	f
18	__mlmsg_wc_exclamation__	tāw	f
20	__mlmsg_wc_idiom__	kīw	f
21	__mlmsg_wc_prefix__	pīa	f
22	__mlmsg_wc_suffix__	pīi	f
23	__mlmsg_wc_partaspect__	pma	f
24	__mlmsg_wc_partprepos__	ptm	f
25	__mlmsg_wc_partpostpos__	pmi	f
19	__mlmsg_wc_interjection__	thu	f
\.

SELECT setval('wordclass_wordclassid_seq',25);

COPY "domain" (domainid, "domain", symbol) FROM stdin;
107	Papatuanuku	Papatuanuku
14	Ruaumoko	Ruaumoko
19	Tumatauenga	Tumatauenga
1	__mlmsg_cat_1000_unassigned__	__mlmsg_cat_1000_unassigned__
2	Haumia	Haumia
3	Hinemoana	Hinemoana
4	Hinengaro	Hinengaro
5	Hinetakurua	Hinetakurua
6	Hineteiwaiwa	Hineteiwaiwa
7	Hinetiotio	Hinetiotio
8	Hinetauoneone	Hinetauoneone
9	Rongo	Rongo
10	Parawhenuamea	Parawhenuamea
11	Ranginui	Ranginui
12	Rehia	Rehia
13	Ruatepupuke	Ruatepupuke
15	Tahu	Tahu
16	Tane	Tane
17	Tangaroa	Tangaroa
18	Tawhirimatea	Tawhirimatea
20	Uru	Uru
21	Wainui	Wainui
22	Whiro	Whiro
108	Hinenuitepo	Hinenuitepo
109	Hineraumati	Hineraumati
110	Mahuika	Mahuika
111	Mareikura	Mareikura
112	Rangianiwaniwa	Rangianiwaniwa
113	Rongo	Rongo
114	Tane te Waiora	Tane te Waiora
115	Tane te Wananga	Tane te Wananga
116	Tiki	Tiki
117	Uenuku	Uenuku
118	Waiora	Waiora
\.

SELECT setval('domain_domainid_seq',118);


COPY borrowedlang (borrowedlangid, borrowedlang) FROM stdin;
1	__mlmsg_borrowed_notborrowed__
2	__mlmsg_borrowed_english__
3	__mlmsg_borrowed_french__
4	__mlmsg_borrowed_german__
5	__mlmsg_borrowed_latin__
\.

SELECT setval('borrowedlang_borrowedlangid_seq',5);

COPY "usage" (usageid, "usage", symbol) FROM stdin;
1	__mlmsg_usage_obscure__	obs
\.

SELECT setval('usage_usageid_seq',1);

COPY tag (tagid, tag) FROM stdin;
1	Te Hiko
2	Te Autō
3	Para Kore
4	Ruaūmoko
5	Te Pūnaha Nakunaku Kai
6	Te Tinana Tangata
7	Koiora Moana
8	Te Aho
9	Ahotakakame
10	He Rau Tuitui
11	Tupu
\.

SELECT setval('tag_tagid_seq',11);

CREATE INDEX headword_mshwid_idx ON headword USING btree (mastersynonymheadwordid);
CREATE INDEX headword_headword_idx ON headword USING btree (headword);
CREATE INDEX headword_categoryid_idx ON headword USING btree (categoryid);
CREATE INDEX headword_owneruserid_idx ON headword USING btree (owneruserid);
CREATE INDEX headword_updateuserid_idx ON headword USING btree (updateuserid);
CREATE INDEX hw_idx_workqueueposition ON headword USING btree (workqueueposition);
CREATE INDEX hw_idx_allocateduserid ON headword USING btree (allocateduserid);
CREATE INDEX hw_idx_mvhwid ON headword USING btree (mastervariantheadwordid);
CREATE INDEX hw_idx_mdhwid ON headword USING btree (masterderivingheadwordid);
CREATE INDEX idx_editorialcomment_headwordid ON editorialcomment USING btree (headwordid);
CREATE INDEX idx_headwordtag_headwordid ON headwordtag USING btree (headwordid);
