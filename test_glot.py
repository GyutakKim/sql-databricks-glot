import sqlglot


with open("sample.sql", "r") as fp:
    query = fp.read()
    parsed_q = sqlglot.parse(query)

    print(parsed_q)
