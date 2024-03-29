////////////////////////////////////////////////////////////////////////////////
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
// CONSTRAINTS AND INDEXES
//
// 1. Create unique constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT n.property IS UNIQUE;
//
// 2. Create a single-property index
// CREATE INDEX ON :Label(property);
//
// 3. Create a composite index
// CREATE INDEX ON :Label(prop1, …​, propN);
//
// 4. Create node property existence constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT EXISTS(n.property);
//
// 5. Create relationship property existence constraint
// CREATE CONSTRAINT ON ()-[r:relationshipType]-() ASSERT EXISTS(r.property);
//
// 6. Create a Node Key
// ASSERT (variable.propertyName_1, …​, variable.propertyName_n) IS NODE KEY;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Unique constraints & Indexes
//
////////////////////////////////////////////////////////////////////////////////
//
CREATE CONSTRAINT ON (n:Person) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:Company) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:University) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:Innovation) ASSERT n.name IS UNIQUE;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// List all constraints
CALL db.constraints();
//
// List all indexes
CALL db.indexes();
//
// Wait for all indexes online
CALL db.awaitIndexes();
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Call the nlp micro service to process the documents.
//
CALL apoc.custom.asProcedure(
  'nlp_import',
  'WITH $n AS n
    CALL apoc.load.jsonParams($nlp_service, {method: "POST"}, $input)
      YIELD value
  WITH n, value
    UNWIND value AS document
  WITH n, document
    UNWIND document.p AS sentence

  WITH n, sentence
    UNWIND sentence.e AS entity
  WITH n, sentence, entity
    MERGE (e:NAMED_ENTITY {c: entity.c})
      ON CREATE SET e.n = 1
      ON MATCH SET e.n = e.n + 1
    MERGE (n)-[r:HAS_NAMED_ENTITY]->(e)
      ON CREATE SET r.n = 1
      ON MATCH SET r.n = r.n + 1
  WITH n, sentence, e, entity
    CALL apoc.create.addLabels(e, ["NAMED_ENTITY_" + entity.t]) YIELD node
  WITH n, sentence, node AS e, entity
    UNWIND entity.w AS word
      MERGE (w:WORD {l: word.l})
        ON CREATE SET w.n = 1
        ON MATCH SET w.n = w.n + 1
      MERGE (e)-[r:HAS_WORD]->(w)

  WITH n, sentence
    UNWIND sentence.k AS key_phrase
  WITH n, sentence, key_phrase
    MERGE (k:KEY_PHRASE {c: key_phrase.c})
      ON CREATE SET k.n = 1
      ON MATCH SET k.n = k.n + 1
    MERGE (n)-[r:HAS_KEY_PHRASE]->(k)
      ON CREATE SET r.n = 1
      ON MATCH SET r.n = r.n + 1
  WITH n, sentence, k, key_phrase
    UNWIND key_phrase.w AS word
      MERGE (w:WORD {l: word.l})
        ON CREATE SET w.n = 1
        ON MATCH SET w.n = w.n + 1
      MERGE (k)-[r:HAS_WORD]->(w)
        ON CREATE SET r.c = word.c
  RETURN n AS result;',
  'write',
  [['result','NODE']],
  [['n','NODE'], ['nlp_service','STRING'], ['input','STRING']]
);
//
CALL apoc.custom.list;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// CALL apoc.custom.list;
//
// CALL apoc.custom.removeProcedure('nlp_import');
//
////////////////////////////////////////////////////////////////////////////////
