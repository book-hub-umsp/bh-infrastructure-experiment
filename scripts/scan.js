import { request, gql } from 'graphql-request';

const endpoint = process.env.GRAPHQL_ENDPOINT || 'http://localhost:4000/graphql';

const introspectionQuery = gql`
  query IntrospectionQuery {
    __schema {
      queryType { name }
      mutationType { name }
      types {
        name
        kind
        description
        fields {
          name
          type {
            name
            kind
          }
        }
      }
    }
  }
`;

console.log(`🔍 Sending introspection query to: ${endpoint}...\n`);

try {
  const data = await request(endpoint, introspectionQuery);
  console.log('GraphQL schema introspection succeeded.\n');
  console.log(JSON.stringify(data, null, 2));
} catch (error) {
  console.error('Failed to fetch GraphQL schema:', error.message || error);
  process.exit(1);
}
