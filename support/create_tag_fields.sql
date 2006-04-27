CREATE TABLE tag (
   tagid   SERIAL    PRIMARY KEY,
   tag     TEXT
);

INSERT INTO tag (tag) VALUES ('Class: Science');
INSERT INTO tag (tag) VALUES ('Class: Science - Biology');
INSERT INTO tag (tag) VALUES ('Class: Science - Physics');
INSERT INTO tag (tag) VALUES ('Class: Maths');
INSERT INTO tag (tag) VALUES ('Class: Maths: Algebra');
INSERT INTO tag (tag) VALUES ('Class: Maths: Geometry');

CREATE TABLE headwordtag (
   headwordtagid  SERIAL   PRIMARY KEY,
   headwordid     int  REFERENCES headword ,
   tagid          int  REFERENCES tag
);

CREATE INDEX idx_headwordtag_headwordid on headwordtag(headwordid);
