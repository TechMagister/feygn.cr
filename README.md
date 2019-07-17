# feygn

[POC] Http Client made easy ?

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     feygn:
       github: TechMagister/feygn.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "json"

require "feygn"

include Feygn::Annotations
include Feygn

class User 
  JSON.mapping(
    id: Int32?,
    email: String?,
    first_name: String?,
    last_name: String?,
    avatar: String?,
  )
end

class UserData
  JSON.mapping(
    user: {key: "data", type: User?}
  )  
end

class UserList
  JSON.mapping(
    page: Int32,
    per_page: Int32,
    total: Int32,
    total_pages: Int32?,
    data: Array(User)?
  )  
end

@[FeygnClient(name: "ReqRes", url: "https://reqres.in")]
class ReqResClient
  feygn_client
  
  def user(id : Int32) : User?
    data = get_user(id)
    data.user if data
  end
  
  def users(page) : Array(User)?
    paged = list_users(page)
    paged.data if paged
  end
  
  @[GetMapping("/api/users?page={page}", produces: "application/json")]
  private def list_users(page) : UserList
    feygn_call
  end

  @[GetMapping("/api/users/{id}", produces: "application/json")]
  private def get_user(id : Int32) : UserData
    feygn_call(parse: true) # Setting parse to false will require the following return type : Halite::Response
  end
  
  
end

client = ReqResClient.new
client.user(2)
client.users(2)
```

## Development

- [x] POC
- [ ] Implements all HTTP verbs

## Contributing

1. Fork it (<https://github.com/TechMagister/feygn.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Arnaud Fernandés](https://github.com/TechMagister) - creator and maintainer
