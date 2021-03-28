# paypal_mafia

[The "PayPal Mafia"](https://en.wikipedia.org/wiki/PayPal_Mafia) is a group of former PayPal employees and founders who have since founded and developed additional technology companies such as Tesla, Inc., LinkedIn, Palantir Technologies, SpaceX, Affirm, Slide, Kiva, YouTube, Yelp, and Yammer. Most of the members attended Stanford University or University of Illinois at Urbana–Champaign at some point in their studies.

Here's a look into the mafia using network science (neo4j graph) [Presentation](doc/paypal_mafia.pdf).

## How to set this up in the cloud

*If you have only 5 mins and don't care if you want to keep it on your own machine*

- Go to create a [neo4j sandbox](https://neo4j.com/sandbox/), click on 'Launch a Free Sandbox', agree to the terms, launch a blank sandbox, click on 'Open' green button to open a browser tab to access the sandbox.
- first, copy the context of this [Cypher query](cql/step_2_custom_schema.cql), paste it into the query box, click on the blue button to run it.
- second, copy the context of this [Cypher query](cql/step_3_case_study_import.cql), paste it into the query box, click on the blue button to run it.

## How to set this up on your computer

*If you can deal with Docker and has admin right to your own machine*

To run it on your computer (macOS or Linux)
- install Docker Desktop (Docker & Docker Compose)
- checkout the repository:

        git clone https://github.com/nghia71/paypal_mafia.git
        cd feasible-path

- create and run neo4j docker:

        ./run.sh

- open your browser, go to http://localhost:7474, enter with username `neo4j`, password `path`
- first, copy the context of this [Cypher query](cql/step_2_custom_schema.cql), paste it into the query box, click on the blue button to run it.
- second, copy the context of this [Cypher query](cql/step_3_case_study_import.cql), paste it into the query box, click on the blue button to run it.

## What are the queries

Paypal people

    MATCH (c:Company {name: "Paypal"})-[]-(p:Person) RETURN c, p


Paypal accomplishment

    MATCH (i:Innovation)-[]-(c:Company {name: "Paypal"}) RETURN c, i

Steve Chen, Chad Hurley, Jawed Karim accomplishment

    MATCH (p:Person)-[]-(c1:Company)
        WHERE p.name IN ['Steve Chen', 'Chad Hurley', 'Jawed Karim']
    WITH p, c1
        OPTIONAL MATCH (c1)-[]-(i1:Innovation)
    WITH p, c1, i1
        OPTIONAL MATCH (c1)-[]-(c2:Company)
            WHERE TYPE(r) <> 'OWNS'
    WITH p, c1, i1, c2
        OPTIONAL MATCH (c2)-[]-(i2:Innovation)
    RETURN i1, i2