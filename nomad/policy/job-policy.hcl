namespace "book-hub" {
  policy = "write"
  variables {
    path "book-hub*" {
      capabilities = ["write", "read", "destroy", "list"]
    }
    path "book-hub/secret*" {
      capabilities = ["write", "read", "destroy", "list"]
    }
  }
}

namespace "default" {
  policy = "read"
  variables {
    path "hc1*" {
      capabilities = ["read"]
    }
  }
}

