namespace "book-hub" {
  policy       = "read"
  capabilities = [
    "read-logs",
    "list-jobs",
    "dispatch-job",
    "read-job"
    ]
  
  variables {
    path "book-hub*" {
      capabilities = ["read"]
    }
    path "book-hub/secret*" {
      capabilities = ["read"]
    }
  }
}

namespace "default" {
  policy = "deny"
}

node {
  policy = "read"
}

namespace "book-hub" {
  policy       = "write"
  capabilities = [
    "read-logs"
  ]
}
