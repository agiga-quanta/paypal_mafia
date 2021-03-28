////////////////////////////////////////////////////////////////////////////////
//
:param xlsx_file => 'https://github.com/nghia71/paypal_mafia/raw/main/import/paypal-mafia.xlsx';


CALL apoc.load.xls($xlsx_file, 'person!A1:E23')
	YIELD map
WITH map
  MERGE (p:Person {name: map.name})
    SET
      p.born = map.born,
      p.country = map.country,
      p.entry = map.entry,
      p.worth = TOFLOAT(map.worth);
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
CALL apoc.load.xls($xlsx_file, 'person-education!A1:G29')
  YIELD map
WITH map
  MERGE (p:Person {name: map.name})
WITH map, p
  MERGE (u:University {name: map.university})
    SET
      u.country = map.country,
      u.rank = map.rank
  MERGE (p)-[r:STUDIED_AT]->(u)
    SET
      r.from = map.from,
      r.to = map.to,
      r.title = map.title;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
CALL apoc.load.xls($xlsx_file, 'company-company!A1:C17')
  YIELD map
WITH map
  MERGE (c:Company {name: map.name})
  MERGE (o:Company {name: map.company})
WITH map, c, o
  CALL apoc.merge.relationship(c, TOUPPER(REPLACE(map.what, ' ', '_')), {}, {}, o, {}) YIELD rel
RETURN COUNT(DISTINCT(map));
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
CALL apoc.load.xls('/paypal-mafia.xlsx', 'person-company!A1:G103')
  YIELD map
WITH map
  MERGE (p:Person {name: map.name})
WITH map, p
  MERGE (c:Company {name: map.company})
    SET
      c.description = map.description,
      c.worth = ROUND(TOFLOAT(map.worth))
WITH map, p, c, SPLIT(map.title, '|') AS title_list
WITH map, p, c, title_list
  UNWIND title_list AS title
WITH map, p, c, title
  CALL apoc.merge.relationship(p, TOUPPER(REPLACE(title, ' ', '_')), {}, {}, c, {}) YIELD rel
  SET
    rel.from = map.from,
    rel.to = map.to;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
CALL apoc.load.xls($xlsx_file, 'innovation-company!A1:E69')
  YIELD map
WITH map
  MERGE (c:Company {name: map.company})
WITH map, c
  MERGE (i:Innovation {name: map.name})
  MERGE (c)-[r:MADE]->(i)
    SET
      r.when = map.when,
      i.users = map.users,
      i.type = map.type;
//
////////////////////////////////////////////////////////////////////////////////