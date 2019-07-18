# feygn

[POC] Http Client made easy (and transarent) ?

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
# file: req_res_client.cr
require "json"
require "feygn"

require "./your_own_data_structures" #sample below

include Feygn::Annotations
include Feygn

@[FeygnClient(name: "ReqRes", endpoint: "https://reqres.in", logging: true)]
@[Headers({"User-Agent": "ReqResClient"})]
class ReqResClient
  feygn_client
  
  def user(id : Int32) : User?
    user = get_user(id)
    user.data if user
  end
  
  def users(page) : Array(User)?
    paged = list_users(page)
    paged.data if  paged
  end
  
  @[RequestLine("POST /api/users", produces: "application/json")]
  @[Body("user", type: "json")]
  @[Headers({"Content-Type": "application/json"})]
  def create(user : NamedTuple) : UserLight
    feygn_call
  end
  
  @[RequestLine("GET /api/users", produces: "application/json")]
  @[QueryParams({"page" => "{page}"})]
  private def list_users(page) : UserList
    feygn_call
  end

  @[RequestLine("GET /api/users/{id}", produces: "application/json")]
  private def get_user(id : Int32) : UserData
    feygn_call(parse: true) # set to false or remove produces to get the Halite::Response object
  end
  
end
```

```crystal
# file: your_own_data_structures.cr
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
  JSON.mapping(data: User?)  
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

class UserLight
  JSON.mapping(
    name: String?,
    job: String?,
    id: String?,
    createdAt: String?
  )
  def initialize(@name, @job) end
end
```

```crystal
# file: main.cr
test_client = ReqResClient.new
test_client.user(2)
test_client.users(page: 1)
test_client.create({"name": "morpheus", "job": "leader"})

test_client.client # => Halite::Client

```

## Development

- [x] POC
- [x] Implements all HTTP verbs
- [ ] Add tests (yes, it's still a poc)
- [ ] Improve the API

## Contributing

1. Fork it (<https://github.com/TechMagister/feygn.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Arnaud Fernandés](https://github.com/TechMagister) - creator and maintainer
